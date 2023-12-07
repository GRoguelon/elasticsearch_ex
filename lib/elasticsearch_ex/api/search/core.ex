defmodule ElasticsearchEx.Api.Search.Core do
  @moduledoc """
  Search APIs are used to search and aggregate data stored in Elasticsearch indices and data streams. For an overview and related tutorials, see [The search API](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-your-data.html).

  Most search APIs support [multi-target syntax](https://www.elastic.co/guide/en/elasticsearch/reference/current/api-conventions.html#api-multi-index), with the exception of the [explain API](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-explain.html).
  """

  alias ElasticsearchEx.Client

  @typedoc "Represents the body expected by the search API."
  @type search_body :: map()

  @typedoc "The possible individual options accepted by the search function.s"
  @type search_opt :: {:index, atom() | binary()}

  @typedoc "The possible options accepted by the search function.s"
  @type search_opts :: [search_opt() | {atom(), any()}]

  @doc """
  Returns search hits that match the query defined in the request.

  It expects the first argument to be a valid Elasticsearch query represented by an Elixir `Map`.

  ### Examples

      iex> ElasticsearchEx.Api.Search.Core.search(%{query: %{match_all: %{}}, size: 1})
      {:ok,
       %{
         "_shards" => %{
           "failed" => 0,
           "skipped" => 0,
           "successful" => 0,
           "total" => 0
         },
         "hits" => %{"hits" => [], "max_score" => 0.0},
         "timed_out" => false,
         "took" => 0
       }}
  """
  @spec search(search_body(), search_opts()) :: Client.response()
  def search(query, opts \\ []) when is_map(query) and is_list(opts) do
    {index, opts} = Keyword.pop(opts, :index, :_all)

    Client.post("/#{index}/_search", nil, query, opts)
  end
end
