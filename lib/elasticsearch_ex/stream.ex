defmodule ElasticsearchEx.Stream do
  @moduledoc """
  Provides an utility to generate an Elixir `Stream` from an Elasticsearch search.
  """

  require Logger

  alias ElasticsearchEx.Api.Search, as: SearchApi

  ## Types

  @type query :: ElasticsearchEx.query()

  @type index :: ElasticsearchEx.index()

  @type pit :: %{required(:id) => binary(), required(:keep_alive) => binary()}

  @type search_after :: []

  @type acc :: {pit(), nil | search_after()}

  ## Module attributes

  @sort_shard_doc [%{_shard_doc: :asc}]

  ## Public functions

  @doc """
  Runs an Elasticsearch by returning a `Stream` which is perfect for browsing large volume of data.

  ## Examples

      iex> ElasticsearchEx.Stream.stream(%{query: %{match_all: %{}}, sort: [%{"@timestamp" => "desc"}]}, "my_index", keep_alive: "30s", per_page: 500)
      #Function<52.124013645/2 in Stream.resource/3>
  """
  @spec stream(query(), nil | index(), keyword()) :: Enumerable.t()
  def stream(query, index \\ nil, params \\ []) do
    {keep_alive, params} = Keyword.pop(params, :keep_alive, "10s")
    {per_page, params} = Keyword.pop(params, :per_page, 100)
    prepared_query = prepare_query(query, per_page)

    Stream.resource(start_fun(index, keep_alive), next_fun(prepared_query, params), &after_fun/1)
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

  @spec next_fun(query(), keyword()) :: (acc() -> {[] | :halt, acc()})
  defp next_fun(query, params) do
    fn {pit, search_after} ->
      query = query |> generate_pit_query(pit) |> generate_search_after_query(search_after)

      Logger.debug(
        "Searching through the PIT: #{pit.id} and search_after: #{inspect(search_after)}"
      )

      case SearchApi.search(query, nil, params) do
        {:ok, %{"hits" => %{"hits" => []}}} ->
          {:halt, {pit, search_after}}

        {:ok, %{"hits" => %{"hits" => hits}}} ->
          search_after = hits |> List.last() |> Map.fetch!("sort")

          {hits, {pit, search_after}}

        any ->
          raise "unknown result: #{inspect(any)}"
      end
    end
  end

  @spec after_fun(acc()) :: any()
  defp after_fun({%{id: pit_id}, _search_after}) do
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
