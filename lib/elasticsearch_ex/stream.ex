defmodule ElasticsearchEx.Stream do
  @moduledoc """
  Provides an utility to generate an Elixir `Stream` from an Elasticsearch search.
  """

  require Logger

  import ElasticsearchEx.Guards, only: [is_name!: 1]

  alias ElasticsearchEx.Api.Search, as: SearchApi

  ## Types

  @type query :: ElasticsearchEx.query()

  @type index :: ElasticsearchEx.index()

  @type opts :: ElasticsearchEx.opts()

  @typep pit :: %{required(:id) => binary(), required(:keep_alive) => binary()}

  @typep search_after :: []

  @typep acc :: {pit(), nil | :end_of_stream | search_after()}

  ## Module attributes

  @sort_shard_doc [%{_shard_doc: :asc}]

  ## Public functions

  @doc since: "1.5.0"
  @spec stream(query()) :: Enumerable.t()
  def stream(query) do
    stream(query, nil, [])
  end

  @doc since: "1.5.0"
  def stream(query, index_or_opts)

  @spec stream(query(), index()) :: Enumerable.t()
  def stream(query, index) when is_name!(index) do
    stream(query, index, [])
  end

  @spec stream(query(), opts()) :: Enumerable.t()
  def stream(query, opts) when is_list(opts) do
    stream(query, nil, opts)
  end

  @doc """
  Runs an Elasticsearch by returning a `Stream` which is perfect for browsing large volume of data.

  ## Examples

      iex> ElasticsearchEx.Stream.stream(
      ...>   %{query: %{match_all: %{}}, sort: [%{message: :desc}]},
      ...>   :my_index,
      ...>   keep_alive: "30s",
      ...>   per_page: 500
      ...> )
      #Function<52.124013645/2 in Stream.resource/3>
  """
  @doc since: "1.3.0"
  @spec stream(query(), nil | index(), opts()) :: Enumerable.t()
  def stream(query, index, opts) do
    {keep_alive, opts} = Keyword.pop(opts, :keep_alive, "10s")
    {per_page, opts} = Keyword.pop(opts, :per_page, 100)
    prepared_query = prepare_query(query, per_page)

    Stream.resource(start_fun(index, keep_alive), next_fun(prepared_query, opts), &after_fun/1)
  end

  ## Private functions

  @spec start_fun(index(), binary()) :: (() -> acc())
  defp start_fun(index, keep_alive) do
    fn ->
      {:ok, %{"id" => pit_id}} = SearchApi.create_pit(index, keep_alive: keep_alive)

      Logger.debug("Created the PIT: #{pit_id}")

      {%{id: pit_id, keep_alive: keep_alive}, nil}
    end
  end

  @spec next_fun(query(), keyword()) :: (acc() -> {:halt, pit()} | {nonempty_list(), acc()})
  defp next_fun(query, params) do
    per_page = Map.fetch!(query, :size)

    &do_next_fun(&1, query, params, per_page)
  end

  @spec do_next_fun(acc(), map(), keyword(), pos_integer()) ::
          {:halt, pit()} | {nonempty_list(), acc()}
  defp do_next_fun({pit, :end_of_stream}, _query, _params, _per_page) do
    {:halt, pit}
  end

  defp do_next_fun({pit, search_after}, query, params, per_page) do
    query = query |> generate_pit_query(pit) |> generate_search_after_query(search_after)

    Logger.debug(
      "Searching through the PIT: #{pit.id} and search_after: #{inspect(search_after)}"
    )

    case SearchApi.search(query, params) do
      {:ok, %{"hits" => %{"hits" => []}}} ->
        {:halt, pit}

      {:ok, %{"hits" => %{"hits" => hits}}} ->
        if length(hits) < per_page do
          {hits, {pit, :end_of_stream}}
        else
          search_after = hits |> List.last() |> Map.fetch!("sort")

          {hits, {pit, search_after}}
        end

      any ->
        raise "unknown result: #{inspect(any)}"
    end
  end

  @spec after_fun(acc()) :: :ok
  defp after_fun({pit, _search_after}), do: after_fun(pit)

  @spec after_fun(pit()) :: :ok
  defp after_fun(%{id: pit_id}) do
    case SearchApi.close_pit(pit_id) do
      {:ok, %{"num_freed" => _, "succeeded" => true}} ->
        Logger.debug("Deleted the PIT: #{pit_id}")

      {:error, _error} ->
        Logger.error("Unable to delete the PIT: #{pit_id}")
    end
  end

  @spec prepare_query(query(), pos_integer()) :: query()
  defp prepare_query(query, per_page) do
    query
    |> Map.put(:size, per_page)
    |> Map.put(:track_total_hits, false)
    |> Map.update(:sort, @sort_shard_doc, &(&1 ++ @sort_shard_doc))
  end

  @spec generate_pit_query(query(), pit()) :: query()
  defp generate_pit_query(query, pit) when is_map(pit) do
    Map.put(query, :pit, pit)
  end

  @spec generate_search_after_query(query(), nil | list()) :: query()
  defp generate_search_after_query(query, search_after) when is_list(search_after) do
    Map.put(query, :search_after, search_after)
  end

  defp generate_search_after_query(query, _search_after), do: query
end
