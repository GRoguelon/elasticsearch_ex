defmodule ElasticsearchEx.MappingsCacher do
  @moduledoc """
  Defines a `GenServer` to keep in cache the Elasticsearch mappings.

  It accepts an optional option:

      config :elasticsearch_ex, time_to_leave: :timer.minutes(30)

  When defined, it refreshes the mapping in cache.
  """

  use GenServer

  require Logger

  ## Public functions

  def start_link(init_args) do
    {name, init_args} = Keyword.pop(init_args, :name, __MODULE__)
    opts = [name: name]

    GenServer.start_link(__MODULE__, init_args, opts)
  end

  def get(pid \\ __MODULE__, index_name) do
    GenServer.call(pid, {:get, index_name})
  end

  def delete(pid \\ __MODULE__, index_name) do
    GenServer.cast(pid, {:delete, index_name})
  end

  def clear(pid \\ __MODULE__) do
    GenServer.cast(pid, :clear)
  end

  ## Callbacks

  @impl true
  def init(opts) do
    time_to_live = Keyword.get(opts, :time_to_live)
    mappings = fetch_all_mappings!(time_to_live)

    if is_integer(time_to_live) do
      schedule_cleanup(mappings)
    end

    {:ok, %{mappings: mappings, time_to_live: time_to_live}}
  end

  @impl true
  def handle_call({:get, index_name}, _from, %{mappings: mappings} = state) do
    case Map.get(mappings, index_name) do
      {_expiration, mapping} ->
        {:reply, mapping, state}

      nil ->
        {mapping, %{mappings: new_mappings} = new_state} = update_mapping_state(state, index_name)

        schedule_cleanup(new_mappings)

        {:reply, mapping, new_state}
    end
  end

  @impl true
  def handle_cast({:delete, index_name}, %{mappings: mappings} = state) do
    mappings = Map.delete(mappings, index_name)

    {:noreply, %{state | mappings: mappings}}
  end

  @impl true
  def handle_cast(:clear, %{time_to_live: time_to_live} = state) do
    mappings = fetch_all_mappings!(time_to_live)

    {:noreply, %{state | mappings: mappings}}
  end

  @impl true
  def handle_info(:clean_expired_mappings, state) do
    %{mappings: mappings, time_to_live: time_to_live} = state
    current_timestamp = current_timestamp()

    expired_index_names =
      Enum.reduce(mappings, [], fn {index_name, {expiration, _value}}, acc ->
        if expiration <= current_timestamp do
          [index_name | acc]
        else
          acc
        end
      end)

    renewed_mappings = fetch_mappings!(expired_index_names, time_to_live)
    new_mappings = Map.merge(mappings, renewed_mappings)

    Logger.debug("Cleaning up expired mappings (#{length(expired_index_names)})")

    schedule_cleanup(new_mappings, current_timestamp)

    {:noreply, %{state | mappings: new_mappings}}
  end

  ## Private functions

  defp schedule_cleanup(mappings, current_timestamp \\ current_timestamp()) do
    case Enum.min_by(mappings, fn {_, {expiration, _}} -> expiration end, fn -> nil end) do
      {_index_name, {expiration, _mapping}} when is_integer(expiration) ->
        if expiration <= current_timestamp do
          send(self(), :clean_expired_mappings)
        else
          Process.send_after(self(), :clean_expired_mappings, expiration - current_timestamp)
        end

      _ ->
        nil
    end
  end

  defp update_mapping_state(%{time_to_live: time_to_live, mappings: mappings} = state, index_name) do
    new_mappings = fetch_mappings!(index_name, time_to_live)
    {_expiration, mapping} = Map.fetch!(new_mappings, index_name)
    new_state = %{state | mappings: Map.merge(mappings, new_mappings)}

    {mapping, new_state}
  end

  defp fetch_all_mappings!(time_to_live) do
    result = ElasticsearchEx.Client.request(:get, "/_mappings")

    parse_mappings!(result, time_to_live)
  end

  defp fetch_mappings!(index_names, time_to_live) when is_list(index_names) do
    index_names
    |> Enum.join(",")
    |> fetch_mappings!(time_to_live)
  end

  defp fetch_mappings!(index_name, time_to_live) do
    result = ElasticsearchEx.Client.request(:get, "/#{index_name}/_mapping")

    parse_mappings!(result, time_to_live)
  end

  defp parse_mappings!({:ok, mappings}, time_to_live) do
    timestamp = current_timestamp()
    expiration = time_to_live && timestamp + time_to_live

    Map.new(mappings, fn {index_name, mapping} ->
      {index_name, {expiration, mapping["mappings"]}}
    end)
  end

  defp parse_mappings!(error, _time_to_live) do
    raise "Unknown error: #{inspect(error)}"
  end

  defp current_timestamp, do: DateTime.utc_now(:millisecond) |> DateTime.to_unix(:millisecond)
end
