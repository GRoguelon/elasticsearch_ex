defmodule ElasticsearchEx.Api.Search.Core do
  @moduledoc """
  Search APIs are used to search and aggregate data stored in Elasticsearch indices and data streams. For an overview and related tutorials, see [The search API](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-your-data.html).

  Most search APIs support [multi-target syntax](https://www.elastic.co/guide/en/elasticsearch/reference/current/api-conventions.html#api-multi-index), with the exception of the [explain API](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-explain.html).
  """

  import ElasticsearchEx.Api.Utils,
    only: [extract_index!: 1, extract_index: 1, merge_path_suffix: 2]

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

  @typedoc "Represents the body expected by the `multi_search` API."
  @type multi_search_body :: Enumerable.t()

  @typedoc "The possible individual options accepted by the `multi_search` function."
  @type multi_search_opt :: {:index, atom() | binary()}

  @typedoc "The possible options accepted by the `multi_search` function."
  @type multi_search_opts :: [search_opt() | {:http_opts, keyword()} | {atom(), any()}]

  @doc """
  Executes several searches with a single API request.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-multi-search.html#search-multi-search-api-query-params)
  for a detailed list of the parameters.

  ### Request body

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-multi-search.html#search-multi-search-api-request-body)
  for a detailed list of the body values.

  ### Examples

      iex> ElasticsearchEx.Api.Search.Core.multi_search(
      ...>   [
      ...>     %{},
      ...>     %{"query" => %{"match" => %{"message" => "this is a test"}}},
      ...>     %{"index" => "my-index-000002"},
      ...>     %{"query" => %{"match_all" => %{}}}
      ...>   ],
      ...>   allow_no_indices: false
      ...> )
      {:ok,
       %{
         "responses" => [
           %{
             "_shards" => %{
               "failed" => 0,
               "skipped" => 0,
               "successful" => 2,
               "total" => 2
             },
             "hits" => %{
               "hits" => [
                %{
                   "_id" => "8-aORIwBU7w6JJjT4O86",
                   "_index" => "my-index-000001",
                   "_score" => 1.0,
                   "_source" => %{
                     "message": "this is a test"
                   }
                 }
               ],
               "max_score" => nil,
               "total" => %{"relation" => "eq", "value" => 0}
             },
             "status" => 200,
             "timed_out" => false,
             "took" => 14
           },
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
                   "_id" => "8uaORIwBU7w6JJjTX-8-",
                   "_index" => "my-index-000002",
                   "_score" => 1.0,
                   "_source" => %{
                     "message": "this another test"
                   }
                 }
               ],
               "max_score" => 1.0,
               "total" => %{"relation" => "eq", "value" => 3}
             },
             "status" => 200,
             "timed_out" => false,
             "took" => 11
           }
         ],
         "took" => 21
       }}
  """
  @spec multi_search(multi_search_body(), multi_search_opts()) :: Client.response()
  def multi_search(queries, opts \\ []) when is_list(queries) and is_list(opts) do
    {index, opts} = extract_index(opts)
    path = merge_path_suffix(index, "_msearch")
    body = ElasticsearchEx.Ndjson.encode!(queries)

    Client.post(path, %{"content-type" => "application/x-ndjson"}, body, opts)
  end

  @typedoc "Represents the body expected by the `async_search` API."
  @type async_search_body :: map()

  @typedoc "The possible individual options accepted by the `async_search` function."
  @type async_search_opt :: {:index, atom() | binary()}

  @typedoc "The possible options accepted by the `async_search` function."
  @type async_search_opts :: [async_search_opt() | {:http_opts, keyword()} | {atom(), any()}]

  @doc """
  Executes a search request asynchronously. It accepts the same parameters and request body as the
  [search API](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-search.html).

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-search.html#search-search-api-query-params)
  for a detailed list of the parameters.

  ### Request body

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-search.html#search-search-api-request-body)
  for a detailed list of the parameters.

  ### Examples

      iex> ElasticsearchEx.Api.Search.Core.async_search(
      ...>   %{
      ...>     aggs: %{sale_date: %{date_histogram: %{calendar_interval: "1d", field: "date"}}},
      ...>     sort: [%{date: %{order: "asc"}}]
      ...>   },
      ...>   size: 0
      ...> )
      {:ok,
       %{
         "expiration_time_in_millis" => 1584377890986,
         "id" => "FmRldE8zREVEUzA2ZVpUeGs2ejJFUFEaMkZ5QTVrSTZSaVN3WlNFVmtlWHJsdzoxMDc=",
         "is_partial" => true,
         "is_running" => true,
         "response" => %{
           "_shards" => %{
             "failed" => 0,
             "skipped" => 0,
             "successful" => 3,
             "total" => 562
           },
           "hits" => %{
             "hits" => [],
             "max_score" => nil,
             "total" => %{"relation" => "gte", "value" => 157483}
           },
           "num_reduce_phases" => 0,
           "timed_out" => false,
           "took" => 1122
         },
         "start_time_in_millis" => 1583945890986
       }}
  """
  @spec async_search(async_search_body(), async_search_opts()) :: Client.response()
  def async_search(query, opts \\ []) when is_map(query) and is_list(opts) do
    {index, opts} = extract_index(opts)
    path = merge_path_suffix(index, "_async_search")

    Client.post(path, nil, query, opts)
  end

  @typedoc "Represents the ID returned by the `async_search` function."
  @type async_search_id :: binary()

  @doc """
  The get async search API retrieves the results of a previously submitted async search request
  given its id.

  ### Examples

      iex> ElasticsearchEx.Api.Search.Core.get_async_search("FmRldE8zREVEUzA2ZVpUeGs2ejJFUFEaMkZ5QTVrSTZSaVN3WlNFVmtlWHJsdzoxMDc=")
      {:ok,
       %{
         "completion_time_in_millis" => 1583945903130,
         "expiration_time_in_millis" => 1584377890986,
         "id" => "FmRldE8zREVEUzA2ZVpUeGs2ejJFUFEaMkZ5QTVrSTZSaVN3WlNFVmtlWHJsdzoxMDc=",
         "is_partial" => false,
         "is_running" => false,
         "response" => %{
           "_shards" => %{
             "failed" => 0,
             "skipped" => 0,
             "successful" => 188,
             "total" => 562
           },
           "aggregations" => %{"sale_date" => %{"buckets" => []}},
           "hits" => %{
             "hits" => [],
             "max_score" => nil,
             "total" => %{"relation" => "eq", "value" => 456433}
           },
           "num_reduce_phases" => 46,
           "timed_out" => false,
           "took" => 12144
         },
         "start_time_in_millis" => 1583945890986
       }}
  """
  @spec get_async_search(async_search_id(), [{:http_opts, keyword()} | {atom(), any()}]) ::
          Client.response()
  def get_async_search(async_search_id, opts \\ [])
      when is_binary(async_search_id) and is_list(opts) do
    Client.get("/_async_search/#{async_search_id}", nil, nil, opts)
  end

  @doc """
  The get async search status API, without retrieving search results, shows only the status of a
  previously submitted async search request given its id.

  ### Examples

      iex> ElasticsearchEx.Api.Search.Core.get_async_search_status("FmRldE8zREVEUzA2ZVpUeGs2ejJFUFEaMkZ5QTVrSTZSaVN3WlNFVmtlWHJsdzoxMDc=")
      {:ok,
       %{
         "_shards" => %{
           "failed" => 0,
           "skipped" => 0,
           "successful" => 188,
           "total" => 562
         },
         "expiration_time_in_millis" => 1584377890986,
         "id" => "FmRldE8zREVEUzA2ZVpUeGs2ejJFUFEaMkZ5QTVrSTZSaVN3WlNFVmtlWHJsdzoxMDc=",
         "is_partial" => true,
         "is_running" => true,
         "start_time_in_millis" => 1583945890986
       }}
  """
  @spec get_async_search_status(async_search_id(), [{:http_opts, keyword()} | {atom(), any()}]) ::
          Client.response()
  def get_async_search_status(async_search_id, opts \\ [])
      when is_binary(async_search_id) and is_list(opts) do
    Client.get("/_async_search/status/#{async_search_id}", nil, nil, opts)
  end

  @doc """
  You can use the delete async search API to manually delete an async search by ID.
  If the search is still running, the search request will be cancelled. Otherwise, the saved
  search results are deleted.

  ### Examples

      iex> ElasticsearchEx.Api.Search.Core.delete_async_search("FmRldE8zREVEUzA2ZVpUeGs2ejJFUFEaMkZ5QTVrSTZSaVN3WlNFVmtlWHJsdzoxMDc=")
      nil
  """
  @spec delete_async_search(async_search_id(), [{:http_opts, keyword()} | {atom(), any()}]) ::
          Client.response()
  def delete_async_search(async_search_id, opts \\ [])
      when is_binary(async_search_id) and is_list(opts) do
    Client.delete("/_async_search/#{async_search_id}", nil, nil, opts)
  end

  @typedoc "The possible individual options accepted by the `create_pit` function"
  @type create_pit_opt :: {:index, atom() | binary()} | {:keep_alive, binary()}

  @typedoc "The possible options accepted by the `create_pit` function"
  @type create_pit_opts :: [create_pit_opt() | {:http_opts, keyword()} | {atom(), any()}]

  @doc """
  A search request by default executes against the most recent visible data of the target indices,
  which is called point in time. Elasticsearch `pit` (point in time) is a lightweight view into the
  state of the data as it existed when initiated. In some cases, it’s preferred to perform multiple
  search requests using the same point in time. For example, if refreshes happen between
  `search_after` requests, then the results of those requests might not be consistent as changes
  happening between searches are only visible to the more recent point in time.

  ### Examples

      iex> ElasticsearchEx.Api.Search.Core.create_pit(index: :my-index-000001, keep_alive: "5m")
      {:ok,
       %{
         "id" => "gcSHBAEJb2Jhbl9qb2JzFmJsOTBBMHEwUTVld19yQ3RBYkEtSVEAFkF0Q1R5OUhqUXZtazhYaU5oRUVlN3cAAAAAAAAAAFUWdlpGWjkzbEdTM3VUV0tRTFNQMVc5QQABFmJsOTBBMHEwUTVld19yQ3RBYkEtSVEAAA=="
       }}
  """
  @spec create_pit(create_pit_opts()) :: Client.response()
  def create_pit(opts \\ []) when is_list(opts) do
    {index, opts} = extract_index!(opts)

    Client.post("/#{index}/_pit", nil, nil, opts)
  end

  @typedoc "The identifier for a Point in Time"
  @type pit_id :: binary()

  @doc """
  Point-in-time is automatically closed when its `keep_alive` has been elapsed. However keeping
  point-in-times has a cost. Point-in-times should be closed as soon as they are no longer used in
  search requests.

  ### Examples

      iex> ElasticsearchEx.Api.Search.Core.close_pit("gcSHBAEJb2Jhbl9qb2JzFmJsOTBBMHEwUTVld19yQ3RBYkEtSVEAFkF0Q1R5OUhqUXZtazhYaU5oRUVlN3cAAAAAAAAAAFUWdlpGWjkzbEdTM3VUV0tRTFNQMVc5QQABFmJsOTBBMHEwUTVld19yQ3RBYkEtSVEAAA==")
      {:ok, %{"num_freed" => 1, "succeeded" => true}}
  """
  @spec close_pit(pit_id(), [{:http_opts, keyword()} | {atom(), any()}]) :: Client.response()
  def close_pit(pit_id, opts \\ []) when is_binary(pit_id) and is_list(opts) do
    Client.delete("/_pit", nil, %{id: pit_id}, opts)
  end

  @typedoc "Represents the body expected by the `terms_enum` API"
  @type terms_enum_body :: map()

  @typedoc "The possible individual options accepted by the `terms_enum` function"
  @type terms_enum_opt :: {:index, atom() | binary()}

  @typedoc "The possible options accepted by the `terms_enum` function"
  @type terms_enum_opts :: [terms_enum_opt() | {:http_opts, keyword()} | {atom(), any()}]

  @doc """
  The terms enum API can be used to discover terms in the index that match a partial string.

  Supported field types are `keyword`, `constant_keyword`, `flattened`, `version` and `ip`.

  This is used for auto-complete.

  ### Examples

      iex> ElasticsearchEx.Api.Search.Core.terms_enum(%{"field" => "tags", "string" => "kiba"},
      ...>   index: "stackoverflow"
      ...> )
      {:ok,
       %{
         "_shards" => %{"failed" => 0, "successful" => 1, "total" => 1},
         "complete" => true,
         "terms" => ["kibana"]
       }}
  """
  @spec terms_enum(terms_enum_body(), terms_enum_opts()) :: Client.response()
  def terms_enum(query, opts \\ []) when is_map(query) and is_list(opts) do
    {index, opts} = extract_index!(opts)

    Client.post("/#{index}/_terms_enum", nil, query, opts)
  end

  @typedoc "The identifier for a scroll"
  @type scroll_id :: binary()

  @doc """
  Point-in-time is automatically closed when its `keep_alive` has been elapsed. However keeping
  point-in-times has a cost. Point-in-times should be closed as soon as they are no longer used in
  search requests.

  ### Examples

      iex> ElasticsearchEx.Api.Search.Core.get_scroll(
      ...>   "FGluY2x1ZGVfY29udGV4dF91dWlkDXF1ZXJ5QW5kRmV0Y2gBFnZaRlo5M2xHUzN1VFdLUUxTUDFXOUEAAAAAAAAAWRZBdENUeTlIalF2bWs4WGlOaEVFZTd3",
      ...>   scroll: "1m"
      ...> )
      {:ok,
       %{
         "_scroll_id" => "FGluY2x1ZGVfY29udGV4dF91dWlkDXF1ZXJ5QW5kRmV0Y2gBFnZaRlo5M2xHUzN1VFdLUUxTUDFXOUEAAAAAAAAAXRZBdENUeTlIalF2bWs4WGlOaEVFZTd3",
         "_shards" => %{
           "failed" => 0,
           "skipped" => 0,
           "successful" => 1,
           "total" => 1
         },
         "hits" => %{
           "hits" => [],
           "max_score" => nil,
           "total" => %{"relation" => "eq", "value" => 3}
         },
         "timed_out" => false,
         "took" => 1
       }}
  """
  @spec get_scroll(scroll_id(), [{:http_opts, keyword()} | {atom(), any()}]) :: Client.response()
  def get_scroll(scroll_id, opts \\ []) when is_binary(scroll_id) and is_list(opts) do
    Client.post("/_search/scroll", nil, %{scroll_id: scroll_id}, opts)
  end

  @doc """
  Clears the search context and results for a scrolling search.

  ### Examples

      iex> ElasticsearchEx.Api.Search.Core.clear_scroll(
      ...>   "FGluY2x1ZGVfY29udGV4dF91dWlkDXF1ZXJ5QW5kRmV0Y2gBFnZaRlo5M2xHUzN1VFdLUUxTUDFXOUEAAAAAAAAAWRZBdENUeTlIalF2bWs4WGlOaEVFZTd3"
      ...> )
      {:ok, %{"num_freed" => 1, "succeeded" => true}}
  """
  @spec clear_scroll(scroll_id(), [{:http_opts, keyword()} | {atom(), any()}]) ::
          Client.response()
  def clear_scroll(scroll_id, opts \\ []) when is_binary(scroll_id) and is_list(opts) do
    Client.delete("/_search/scroll", nil, %{scroll_id: scroll_id}, opts)
  end
end
