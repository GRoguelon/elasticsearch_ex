defmodule ElasticsearchEx.Streamer do
  @moduledoc """
  Provides an utility to generate an Elixir `Stream` from an Elasticsearch search.
  """

  require Logger

  import ElasticsearchEx.Guards, only: [is_name!: 1]

  alias ElasticsearchEx.API.Search, as: SearchApi
  alias ElasticsearchEx.Deserializer
  alias ElasticsearchEx.MapExt

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
      ...>   %{query: %{match_all: %{}}, sort: [%{message: :desc}], size: 500},
      ...>   :my_index,
      ...>   keep_alive: "30s"
      ...> )
      #Function<52.124013645/2 in Stream.resource/3>
  """
  @doc since: "1.3.0"
  @spec stream(query(), nil | index(), opts()) :: Enumerable.t()
  def stream(query, index, opts) do
    unless Map.has_key?(query, :size) do
      Logger.warning(
        "The `size` option is not set, it is recommended to set it to take advantage of Stream."
      )
    end

    prepared_query = prepare_query(query)
    {pit_id, opts} = Keyword.pop(opts, :pit_id)
    {keep_alive, opts} = Keyword.pop(opts, :keep_alive, "10s")
    {shaper, opts} = pop_shaper(opts)
    pit_id = if(is_binary(pit_id) and pit_alive?(pit_id, opts), do: pit_id)

    do_stream(prepared_query, index, pit_id, keep_alive, shaper, opts)
  end

  ## Private functions

  # `:deserialize` and `:keys_as_atoms` only shape the documents returned to the caller: the
  # Streamer applies them to the yielded hits. They are removed from the options so that all
  # the requests made by the Streamer return raw string-keyed responses.
  @spec pop_shaper(keyword()) :: {(list() -> list()), keyword()}
  defp pop_shaper(opts) do
    {deserialize, opts} = Keyword.pop(opts, :deserialize)
    {keys_as_atoms, opts} = Keyword.pop(opts, :keys_as_atoms)
    key_mapper = if(keys_as_atoms, do: &String.to_atom/1, else: &Function.identity/1)

    shaper =
      cond do
        deserialize == true -> &Deserializer.deserialize(&1, key_mapper)
        keys_as_atoms == true -> &MapExt.map_keys(&1, key_mapper)
        true -> &Function.identity/1
      end

    {shaper, opts}
  end

  defp pit_alive?(pit_id, opts) do
    query = %{query: %{match_none: %{}}, pit: %{id: pit_id}}
    {status, _} = SearchApi.search(query, opts)

    status == :ok
  end

  defp do_stream(query, index, nil, keep_alive, shaper, opts) do
    Stream.resource(
      create_pit(index, keep_alive, opts),
      next_fun(query, shaper, opts),
      &close_pit(&1, opts)
    )
  end

  defp do_stream(query, _index, pit_id, keep_alive, shaper, opts) do
    Stream.resource(
      return_acc(pit_id, keep_alive),
      next_fun(query, shaper, opts),
      &Function.identity/1
    )
  end

  @spec return_acc(binary(), binary()) :: (-> acc())
  defp return_acc(pit_id, keep_alive) do
    fn -> do_return_acc(pit_id, keep_alive) end
  end

  @spec create_pit(index(), binary(), keyword()) :: (-> acc())
  defp create_pit(index, keep_alive, opts) do
    fn ->
      opts =
        Keyword.update(
          opts,
          :params,
          [keep_alive: keep_alive],
          &Keyword.put(&1, :keep_alive, keep_alive)
        )

      case SearchApi.create_pit(index, opts) do
        {:ok, %{"id" => pit_id}} ->
          Logger.debug("Created the PIT: #{pit_id}")

          do_return_acc(pit_id, keep_alive)

        {:error, error} ->
          Logger.error("Unable to create the PIT: #{inspect(error)}")

          raise error
      end
    end
  end

  @spec next_fun(query(), (list() -> list()), keyword()) ::
          (acc() -> {:halt, pit()} | {nonempty_list(), acc()})
  defp next_fun(query, shaper, opts) do
    per_page = Map.get(query, :size, 10)

    fn
      {pit, :end_of_stream} ->
        {:halt, pit}

      {pit, search_after} ->
        Logger.debug("Searching with search_after: #{inspect(search_after)}")

        query
        |> Map.put(:pit, pit)
        |> generate_search_after_query(search_after)
        |> SearchApi.search(opts)
        |> parse_response(pit, per_page)
        |> shape_hits(shaper)
    end
  end

  @spec shape_hits({:halt, pit()} | {nonempty_list(), acc()}, (list() -> list())) ::
          {:halt, pit()} | {nonempty_list(), acc()}
  defp shape_hits({:halt, pit}, _shaper), do: {:halt, pit}
  defp shape_hits({hits, acc}, shaper), do: {shaper.(hits), acc}

  @spec close_pit(acc(), keyword()) :: :ok
  defp close_pit({pit, _search_after}, opts), do: close_pit(pit, opts)

  @spec close_pit(pit(), keyword()) :: :ok
  defp close_pit(%{id: pit_id}, opts) do
    case SearchApi.close_pit(pit_id, opts) do
      {:ok, %{"num_freed" => _, "succeeded" => true}} ->
        Logger.debug("Deleted the PIT: #{pit_id}")

      {:error, _error} ->
        Logger.error("Unable to delete the PIT: #{pit_id}")
    end
  end

  @spec prepare_query(query()) :: query()
  defp prepare_query(query) do
    query
    |> Map.put(:track_total_hits, false)
    |> Map.update(:sort, @sort_shard_doc, &(&1 ++ @sort_shard_doc))
  end

  @spec generate_search_after_query(query(), nil | list()) :: query()
  defp generate_search_after_query(query, search_after) when is_list(search_after) do
    Map.put(query, :search_after, search_after)
  end

  defp generate_search_after_query(query, _search_after), do: query

  @spec do_return_acc(binary(), binary()) :: acc()
  defp do_return_acc(pit_id, keep_alive) do
    {%{id: pit_id, keep_alive: keep_alive}, nil}
  end

  @spec parse_response({:ok | :error, term()}, pit(), pos_integer()) ::
          {:halt, pit()} | {nonempty_list(), acc()}
  defp parse_response({:ok, %{"hits" => %{"hits" => []}}}, pit, _per_page) do
    {:halt, pit}
  end

  defp parse_response({:ok, %{"hits" => %{"hits" => hits}}}, pit, per_page) do
    search_after =
      if length(hits) < per_page do
        :end_of_stream
      else
        hits |> List.last() |> Map.fetch!("sort")
      end

    {hits, {pit, search_after}}
  end

  defp parse_response(any, _pit, _per_page) do
    raise "unknown result: #{inspect(any)}"
  end
end
