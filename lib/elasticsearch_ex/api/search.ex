defmodule ElasticsearchEx.Api.Search do
  @moduledoc """
  Search APIs are used to search and aggregate data stored in Elasticsearch indices and data streams. For an overview and related tutorials, see [The search API](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-your-data.html).

  Most search APIs support [multi-target syntax](https://www.elastic.co/guide/en/elasticsearch/reference/current/api-conventions.html#api-multi-index), with the exception of the [explain API](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-explain.html).
  """

  import ElasticsearchEx.Api.Utils,
    only: [extract_required_index!: 1, extract_optional_index: 1, merge_path_items: 1]

  alias ElasticsearchEx.Client

  ## Module attributes

  @ndjson_headers Client.ndjson()

  ## Public functions

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

      iex> ElasticsearchEx.Api.Search.search(%{query: %{term: %{"user.id": "kimchy"}}},
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
  @spec search(map(), keyword()) :: ElasticsearchEx.response()
  def search(query, opts \\ []) when is_map(query) and is_list(opts) do
    {index, opts} = extract_optional_index(opts)
    path = merge_path_items([index, "_search"])

    Client.post(path, nil, query, opts)
  end

  @doc """
  Executes several searches with a single API request.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-multi-search.html#search-multi-search-api-query-params)
  for a detailed list of the parameters.

  ### Request body

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-multi-search.html#search-multi-search-api-request-body)
  for a detailed list of the body values.

  ### Examples

      iex> ElasticsearchEx.Api.Search.multi_search(
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
  @spec multi_search([map()], keyword()) :: ElasticsearchEx.response()
  def multi_search(queries, opts \\ []) when is_list(queries) and is_list(opts) do
    {index, opts} = extract_optional_index(opts)
    path = merge_path_items([index, "_msearch"])

    Client.post(path, @ndjson_headers, queries, opts)
  end

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

      iex> ElasticsearchEx.Api.Search.async_search(
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
  @spec async_search(map(), keyword()) :: ElasticsearchEx.response()
  def async_search(query, opts \\ []) when is_map(query) and is_list(opts) do
    {index, opts} = extract_optional_index(opts)
    path = merge_path_items([index, "_async_search"])

    Client.post(path, nil, query, opts)
  end

  @doc """
  The get async search API retrieves the results of a previously submitted async search request
  given its id.

  ### Examples

      iex> ElasticsearchEx.Api.Search.get_async_search("FmRldE8zREVEUzA2ZVpUeGs2ejJFUFEaMkZ5QTVrSTZSaVN3WlNFVmtlWHJsdzoxMDc=")
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
  @spec get_async_search(binary(), keyword()) :: ElasticsearchEx.response()
  def get_async_search(async_search_id, opts \\ [])
      when is_binary(async_search_id) and is_list(opts) do
    Client.get("/_async_search/#{async_search_id}", nil, nil, opts)
  end

  @doc """
  The get async search status API, without retrieving search results, shows only the status of a
  previously submitted async search request given its id.

  ### Examples

      iex> ElasticsearchEx.Api.Search.get_async_search_status("FmRldE8zREVEUzA2ZVpUeGs2ejJFUFEaMkZ5QTVrSTZSaVN3WlNFVmtlWHJsdzoxMDc=")
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
  @spec get_async_search_status(binary(), keyword()) :: ElasticsearchEx.response()
  def get_async_search_status(async_search_id, opts \\ [])
      when is_binary(async_search_id) and is_list(opts) do
    Client.get("/_async_search/status/#{async_search_id}", nil, nil, opts)
  end

  @doc """
  You can use the delete async search API to manually delete an async search by ID.
  If the search is still running, the search request will be cancelled. Otherwise, the saved
  search results are deleted.

  ### Examples

      iex> ElasticsearchEx.Api.Search.delete_async_search("FmRldE8zREVEUzA2ZVpUeGs2ejJFUFEaMkZ5QTVrSTZSaVN3WlNFVmtlWHJsdzoxMDc=")
      nil
  """
  @spec delete_async_search(binary(), keyword()) :: ElasticsearchEx.response()
  def delete_async_search(async_search_id, opts \\ [])
      when is_binary(async_search_id) and is_list(opts) do
    Client.delete("/_async_search/#{async_search_id}", nil, nil, opts)
  end

  @doc """
  A search request by default executes against the most recent visible data of the target indices,
  which is called point in time. Elasticsearch `pit` (point in time) is a lightweight view into the
  state of the data as it existed when initiated. In some cases, it’s preferred to perform multiple
  search requests using the same point in time. For example, if refreshes happen between
  `search_after` requests, then the results of those requests might not be consistent as changes
  happening between searches are only visible to the more recent point in time.

  ### Examples

      iex> ElasticsearchEx.Api.Search.create_pit(index: :my-index-000001, keep_alive: "5m")
      {:ok,
       %{
         "id" => "gcSHBAEJb2Jhbl9qb2JzFmJsOTBBMHEwUTVld19yQ3RBYkEtSVEAFkF0Q1R5OUhqUXZtazhYaU5oRUVlN3cAAAAAAAAAAFUWdlpGWjkzbEdTM3VUV0tRTFNQMVc5QQABFmJsOTBBMHEwUTVld19yQ3RBYkEtSVEAAA=="
       }}
  """
  @spec create_pit(keyword()) :: ElasticsearchEx.response()
  def create_pit(opts \\ []) when is_list(opts) do
    {index, opts} = extract_required_index!(opts)

    Client.post("/#{index}/_pit", nil, "", opts)
  end

  @doc """
  Point-in-time is automatically closed when its `keep_alive` has been elapsed. However keeping
  point-in-times has a cost. Point-in-times should be closed as soon as they are no longer used in
  search requests.

  ### Examples

      iex> ElasticsearchEx.Api.Search.close_pit("gcSHBAEJb2Jhbl9qb2JzFmJsOTBBMHEwUTVld19yQ3RBYkEtSVEAFkF0Q1R5OUhqUXZtazhYaU5oRUVlN3cAAAAAAAAAAFUWdlpGWjkzbEdTM3VUV0tRTFNQMVc5QQABFmJsOTBBMHEwUTVld19yQ3RBYkEtSVEAAA==")
      {:ok, %{"num_freed" => 1, "succeeded" => true}}
  """
  @spec close_pit(binary(), keyword()) :: ElasticsearchEx.response()
  def close_pit(pit_id, opts \\ []) when is_binary(pit_id) and is_list(opts) do
    Client.delete("/_pit", nil, %{id: pit_id}, opts)
  end

  @doc """
  The terms enum API can be used to discover terms in the index that match a partial string.

  Supported field types are `keyword`, `constant_keyword`, `flattened`, `version` and `ip`.

  This is used for auto-complete.

  ### Examples

      iex> ElasticsearchEx.Api.Search.terms_enum(%{"field" => "tags", "string" => "kiba"},
      ...>   index: "stackoverflow"
      ...> )
      {:ok,
       %{
         "_shards" => %{"failed" => 0, "successful" => 1, "total" => 1},
         "complete" => true,
         "terms" => ["kibana"]
       }}
  """
  @spec terms_enum(map(), keyword()) :: ElasticsearchEx.response()
  def terms_enum(query, opts \\ []) when is_map(query) and is_list(opts) do
    {index, opts} = extract_required_index!(opts)

    Client.post("/#{index}/_terms_enum", nil, query, opts)
  end

  @doc """
  Point-in-time is automatically closed when its `keep_alive` has been elapsed. However keeping
  point-in-times has a cost. Point-in-times should be closed as soon as they are no longer used in
  search requests.

  ### Examples

      iex> ElasticsearchEx.Api.Search.get_scroll(
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
  @spec get_scroll(binary(), keyword()) :: ElasticsearchEx.response()
  def get_scroll(scroll_id, opts \\ []) when is_binary(scroll_id) and is_list(opts) do
    Client.post("/_search/scroll", nil, %{scroll_id: scroll_id}, opts)
  end

  @doc """
  Clears the search context and results for a scrolling search.

  ### Examples

      iex> ElasticsearchEx.Api.Search.clear_scroll(
      ...>   "FGluY2x1ZGVfY29udGV4dF91dWlkDXF1ZXJ5QW5kRmV0Y2gBFnZaRlo5M2xHUzN1VFdLUUxTUDFXOUEAAAAAAAAAWRZBdENUeTlIalF2bWs4WGlOaEVFZTd3"
      ...> )
      {:ok, %{"num_freed" => 1, "succeeded" => true}}
  """
  @spec clear_scroll(binary(), keyword()) :: ElasticsearchEx.response()
  def clear_scroll(scroll_id, opts \\ []) when is_binary(scroll_id) and is_list(opts) do
    Client.delete("/_search/scroll", nil, %{scroll_id: scroll_id}, opts)
  end
end
