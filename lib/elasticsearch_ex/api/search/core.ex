defmodule ElasticsearchEx.Api.Search.Core do
  @moduledoc """
  Search APIs are used to search and aggregate data stored in Elasticsearch indices and data streams. For an overview and related tutorials, see [The search API](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-your-data.html).

  Most search APIs support [multi-target syntax](https://www.elastic.co/guide/en/elasticsearch/reference/current/api-conventions.html#api-multi-index), with the exception of the [explain API](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-explain.html).
  """

  import ElasticsearchEx.Api.Utils, only: [extract_index: 1, merge_path_suffix: 2]

  alias ElasticsearchEx.Client

  ## Public functions

  @typedoc "Represents the body expected by the `search` API."
  @type search_body :: map()

  @typedoc "The possible individual options accepted by the `search` function."
  @type search_opt :: {:index, atom() | binary()}

  @typedoc "The possible options accepted by the `search` function."
  @type search_opts :: [search_opt() | {:http_opts, keyword()} | {atom(), any()}]

  @doc """
  Returns search hits that match the query defined in the request.

  It expects the first argument to be a valid Elasticsearch query represented by an Elixir `Map`.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-search.html#search-search-api-query-params)
  for a detailed list of the parameters.

  ### Request body

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-search.html#search-search-api-request-body)
  for a detailed list of the body values.

  ### Examples

      iex> ElasticsearchEx.Api.Search.Core.search(%{query: %{term: %{"user.id": "kimchy"}}},
      ...>   from: 40,
      ...>   size: 20
      ...> )
      {:ok,
       %{
         "_shards" => %{
           "failed" => 0,
           "skipped" => 0,
           "successful" => 1,
           "total" => 1
         },
         "hits" => %{
           "hits" => [
             %{
               "_id" => "0",
               "_index" => "my-index-000001",
               "_score" => 1.3862942,
               "_source" => %{
                 "@timestamp" => "2099-11-15T14:12:12",
                 "http" => %{
                   "request" => %{"method" => "get"},
                   "response" => %{"bytes" => 1070000, "status_code" => 200},
                   "version" => "1.1"
                 },
                 "message" => "GET /search HTTP/1.1 200 1070000",
                 "source" => %{"ip" => "127.0.0.1"},
                 "user" => %{"id" => "kimchy"}
               }
             },
             ...
           ],
           "max_score" => 1.3862942,
           "total" => %{"relation" => "eq", "value" => 20}
         },
         "timed_out" => false,
         "took" => 5
       }}
  """
  @spec search(search_body(), search_opts()) :: Client.response()
  def search(query, opts \\ []) when is_map(query) and is_list(opts) do
    {index, opts} = extract_index(opts)
    path = merge_path_suffix(index, "_search")

    Client.post(path, nil, query, opts)
  end
end
