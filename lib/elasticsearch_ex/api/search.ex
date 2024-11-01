defmodule ElasticsearchEx.API.Search do
  @moduledoc """
  Search APIs are used to search and aggregate data stored in Elasticsearch indices and data streams. For an overview and related tutorials, see [The search API](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-your-data.html).

  Most search APIs support [multi-target syntax](https://www.elastic.co/guide/en/elasticsearch/reference/current/api-conventions.html#api-multi-index), with the exception of the [explain API](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-explain.html).
  """

  import ElasticsearchEx.Client, only: [request: 4]

  import ElasticsearchEx.Utils,
    only: [
      compose_indexed_path_prefix: 2,
      compose_indexed_path_suffix: 2,
      compose_indexed_path_suffix: 3
    ]

  import ElasticsearchEx.Guards,
    only: [
      is_enum: 1,
      is_identifier: 1,
      is_name: 1,
      is_name!: 1
    ]

  ## Typespecs

  @type response :: ElasticsearchEx.response()

  @type query :: ElasticsearchEx.query()

  @type index :: ElasticsearchEx.index()

  @type document_id :: ElasticsearchEx.document_id()

  @type opts :: ElasticsearchEx.opts()

  ## Module attributes

  @default_search %{query: %{match_all: %{}}}

  ## Public functions - Core

  @doc """
  Check `search/3` for more information.

  ### Examples

      iex> ElasticsearchEx.API.Search.search()
      {:ok, %{"hits" => %{"hits" => [%{"_id" => "0", "_index" => "my-index-000001", "_source" => %{}}]}}}
  """
  @doc since: "1.5.0"
  @spec search() :: response()
  def search do
    request(:post, "/_search", @default_search, [])
  end

  @doc """
  Check `search/3` for more information.

  ### Examples

  With a query:

      iex> ElasticsearchEx.API.Search.search(%{query: %{term: %{"user.id": "kimchy"}}})
      {:ok, %{"hits" => %{"hits" => [%{"_id" => "0", "_index" => "my-index-000001", "_source" => %{}}]}}}

  With a index:

      iex> ElasticsearchEx.API.Search.search("my-index-000001")
      {:ok, %{"hits" => %{"hits" => [%{"_id" => "0", "_index" => "my-index-000001", "_source" => %{}}]}}}

  With options:

      iex> ElasticsearchEx.API.Search.search(_source: false)
      {:ok, %{"hits" => %{"hits" => [%{"_id" => "0", "_index" => "my-index-000001"}]}}}
  """
  @doc since: "1.5.0"
  def search(query_or_index_or_opts)

  @spec search(query()) :: response()
  def search(query) when is_map(query) do
    search(query, nil, [])
  end

  @spec search(index()) :: response()
  def search(index) when is_name(index) do
    search(@default_search, index, [])
  end

  @spec search(opts()) :: response()
  def search(opts) when is_list(opts) do
    search(@default_search, nil, opts)
  end

  @doc """
  Check `search/3` for more information.

  ### Examples

  With a query and index:

      iex> ElasticsearchEx.API.Search.search(%{query: %{term: %{"user.id": "kimchy"}}}, "my-index-000001")
      {:ok, %{"hits" => %{"hits" => [%{"_id" => "0", "_index" => "my-index-000001", "_source" => %{}}]}}}

  With a index and options:

      iex> ElasticsearchEx.API.Search.search("my-index-000001", _source: false)
      {:ok, %{"hits" => %{"hits" => [%{"_id" => "0", "_index" => "my-index-000001"}]}}}

  With a query and options:

      iex> ElasticsearchEx.API.Search.search(%{query: %{term: %{"user.id": "kimchy"}}}, _source: false)
      {:ok, %{"hits" => %{"hits" => [%{"_id" => "0", "_index" => "my-index-000001"}]}}}
  """
  @doc since: "1.5.0"
  def search(query_or_index, index_or_opts)

  @spec search(query(), nil | index()) :: response()
  def search(query, index) when is_map(query) and is_name(index) do
    search(query, index, [])
  end

  @spec search(nil | index(), opts()) :: response()
  def search(index, opts) when is_name(index) and is_list(opts) do
    search(@default_search, index, opts)
  end

  @spec search(query(), opts()) :: response()
  def search(query, opts) when is_map(query) and is_list(opts) do
    search(query, nil, opts)
  end

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

      iex> ElasticsearchEx.API.Search.search(
      ...>   %{query: %{term: %{"user.id": "kimchy"}}},
      ...>   "my-index-000001",
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
  @doc since: "1.0.0"
  @spec search(query(), nil | index(), opts()) :: response()
  def search(query, index, opts) do
    path = compose_indexed_path_suffix(index, "_search")

    request(:post, path, query, opts)
  end

  @doc "Check `multi_search/3` for more information."
  @doc since: "1.5.0"
  @spec multi_search(Enumerable.t()) :: response()
  def multi_search(queries) when is_enum(queries) do
    multi_search(queries, nil, [])
  end

  @doc "Check `multi_search/3` for more information."
  @doc since: "1.5.0"
  def multi_search(queries, index_or_opts)

  @spec multi_search(Enumerable.t(), nil | index()) :: response()
  def multi_search(queries, index) when is_enum(queries) and is_name(index) do
    multi_search(queries, index, [])
  end

  @spec multi_search(Enumerable.t(), opts()) :: response()
  def multi_search(queries, opts) when is_enum(queries) and is_list(opts) do
    multi_search(queries, nil, opts)
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

      iex> ElasticsearchEx.API.Search.multi_search(
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
  @doc since: "1.0.0"
  @spec multi_search(Enumerable.t(), nil | index(), opts()) :: response()
  def multi_search(queries, index, opts) do
    path = compose_indexed_path_suffix(index, "_msearch")

    request(:post, path, queries, [{:ndjson, true} | opts])
  end

  @doc "Check `async_search/3` for more information."
  @doc since: "1.5.0"
  @spec async_search(query()) :: response()
  def async_search(query) when is_map(query) do
    async_search(query, nil, [])
  end

  @doc "Check `async_search/3` for more information."
  @doc since: "1.5.0"
  def async_search(query, index_or_opts)

  @spec async_search(query(), nil | index()) :: response()
  def async_search(query, index) when is_map(query) and is_name(index) do
    async_search(query, index, [])
  end

  @spec async_search(query(), opts()) :: response()
  def async_search(query, opts) when is_map(query) and is_list(opts) do
    async_search(query, nil, opts)
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

      iex> ElasticsearchEx.API.Search.async_search(
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
  @doc since: "1.0.0"
  @spec async_search(query(), nil | index(), opts()) :: response()
  def async_search(query, index, opts) do
    path = compose_indexed_path_suffix(index, "_async_search")

    request(:post, path, query, opts)
  end

  @doc """
  The get async search API retrieves the results of a previously submitted async search request
  given its id.

  ### Examples

      iex> ElasticsearchEx.API.Search.get_async_search("FmRldE8zREVEUzA2ZVpUeGs2ejJFUFEaMkZ5QTVrSTZSaVN3WlNFVmtlWHJsdzoxMDc=")
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
  @doc since: "1.0.0"
  @spec get_async_search(binary(), opts()) :: response()
  def get_async_search(async_search_id, opts \\ []) when is_identifier(async_search_id) do
    path = compose_indexed_path_prefix("_async_search", async_search_id)

    request(:get, path, nil, opts)
  end

  @doc """
  The get async search status API, without retrieving search results, shows only the status of a
  previously submitted async search request given its id.

  ### Examples

      iex> ElasticsearchEx.API.Search.get_async_search_status("FmRldE8zREVEUzA2ZVpUeGs2ejJFUFEaMkZ5QTVrSTZSaVN3WlNFVmtlWHJsdzoxMDc=")
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
  @doc since: "1.0.0"
  @spec get_async_search_status(binary(), opts()) :: response()
  def get_async_search_status(async_search_id, opts \\ []) when is_identifier(async_search_id) do
    path = compose_indexed_path_prefix("_async_search/status", async_search_id)

    request(:get, path, nil, opts)
  end

  @doc """
  You can use the delete async search API to manually delete an async search by ID.
  If the search is still running, the search request will be cancelled. Otherwise, the saved
  search results are deleted.

  ### Examples

      iex> ElasticsearchEx.API.Search.delete_async_search("FmRldE8zREVEUzA2ZVpUeGs2ejJFUFEaMkZ5QTVrSTZSaVN3WlNFVmtlWHJsdzoxMDc=")
      nil
  """
  @doc since: "1.0.0"
  @spec delete_async_search(binary(), opts()) :: response()
  def delete_async_search(async_search_id, opts \\ []) when is_identifier(async_search_id) do
    path = compose_indexed_path_prefix("_async_search", async_search_id)

    request(:delete, path, nil, opts)
  end

  @doc "Check `create_pit/2` for more information."
  @doc since: "1.5.0"
  @spec create_pit() :: response()
  def create_pit do
    create_pit(nil, [])
  end

  @doc "Check `create_pit/2` for more information."
  @doc since: "1.5.0"
  def create_pit(index_or_opts)

  @spec create_pit(nil | index()) :: response()
  def create_pit(index) when is_name(index) do
    create_pit(index, [])
  end

  @spec create_pit(opts()) :: response()
  def create_pit(opts) do
    create_pit(nil, opts)
  end

  @doc """
  A search request by default executes against the most recent visible data of the target indices,
  which is called point in time. Elasticsearch `pit` (point in time) is a lightweight view into the
  state of the data as it existed when initiated. In some cases, it’s preferred to perform multiple
  search requests using the same point in time. For example, if refreshes happen between
  `search_after` requests, then the results of those requests might not be consistent as changes
  happening between searches are only visible to the more recent point in time.

  ### Examples

      iex> ElasticsearchEx.API.Search.create_pit(index: :my-index-000001, keep_alive: "5m")
      {:ok,
       %{
         "id" => "gcSHBAEJb2Jhbl9qb2JzFmJsOTBBMHEwUTVld19yQ3RBYkEtSVEAFkF0Q1R5OUhqUXZtazhYaU5oRUVlN3cAAAAAAAAAAFUWdlpGWjkzbEdTM3VUV0tRTFNQMVc5QQABFmJsOTBBMHEwUTVld19yQ3RBYkEtSVEAAA=="
       }}
  """
  @doc since: "1.0.0"
  @spec create_pit(nil | index(), opts()) :: response()
  def create_pit(index, opts) do
    path = compose_indexed_path_suffix(index || "_all", "_pit")

    request(:post, path, nil, opts)
  end

  @doc """
  Point-in-time is automatically closed when its `keep_alive` has been elapsed. However keeping
  point-in-times has a cost. Point-in-times should be closed as soon as they are no longer used in
  search requests.

  ### Examples

      iex> ElasticsearchEx.API.Search.close_pit("gcSHBAEJb2Jhbl9qb2JzFmJsOTBBMHEwUTVld19yQ3RBYkEtSVEAFkF0Q1R5OUhqUXZtazhYaU5oRUVlN3cAAAAAAAAAAFUWdlpGWjkzbEdTM3VUV0tRTFNQMVc5QQABFmJsOTBBMHEwUTVld19yQ3RBYkEtSVEAAA==")
      {:ok, %{"num_freed" => 1, "succeeded" => true}}
  """
  @doc since: "1.0.0"
  @spec close_pit(binary(), opts()) :: response()
  def close_pit(pit_id, opts \\ []) when is_identifier(pit_id) do
    request(:delete, "/_pit", %{id: pit_id}, opts)
  end

  @doc """
  The terms enum API can be used to discover terms in the index that match a partial string.

  Supported field types are `keyword`, `constant_keyword`, `flattened`, `version` and `ip`.

  This is used for auto-complete.

  ### Request body

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-terms-enum.html#search-terms-enum-api-request-body)
  for a detailed list of the body values.

  ### Examples

      iex> ElasticsearchEx.API.Search.terms_enum(%{"field" => "tags", "string" => "kiba"},
      ...>   index: "stackoverflow"
      ...> )
      {:ok,
       %{
         "_shards" => %{"failed" => 0, "successful" => 1, "total" => 1},
         "complete" => true,
         "terms" => ["kibana"]
       }}
  """
  @doc since: "1.0.0"
  @spec terms_enum(map(), index()) :: response()
  def terms_enum(query, index, opts \\ []) when is_map(query) and is_name!(index) do
    path = compose_indexed_path_suffix(index, "_terms_enum")

    request(:post, path, query, opts)
  end

  @doc """
  Retrieves the next batch of results for a scrolling search.

  ### Examples

      iex> ElasticsearchEx.API.Search.get_scroll(
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
  @doc since: "1.0.0"
  @spec get_scroll(binary(), opts()) :: response()
  def get_scroll(scroll_id, opts \\ []) when is_binary(scroll_id) do
    request(:post, "/_search/scroll", %{scroll_id: scroll_id}, opts)
  end

  @doc """
  Clears the search context and results for a scrolling search.

  ### Examples

      iex> ElasticsearchEx.API.Search.clear_scroll(
      ...>   "FGluY2x1ZGVfY29udGV4dF91dWlkDXF1ZXJ5QW5kRmV0Y2gBFnZaRlo5M2xHUzN1VFdLUUxTUDFXOUEAAAAAAAAAWRZBdENUeTlIalF2bWs4WGlOaEVFZTd3"
      ...> )
      {:ok, %{"num_freed" => 1, "succeeded" => true}}
  """
  @doc since: "1.0.0"
  @spec clear_scroll(binary(), opts()) :: response()
  def clear_scroll(scroll_id, opts \\ []) when is_binary(scroll_id) do
    request(:delete, "/_search/scroll", %{scroll_id: scroll_id}, opts)
  end

  ## Public functions - Testing

  @doc """
  Returns information about why a specific document matches (or doesn’t match) a query.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-explain.html#search-explain-api-query-params)
  for a detailed list of the parameters.

  ### Request body

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-explain.html#search-explain-api-request-body)
  for a detailed list of the body values.

  """
  @doc since: "1.0.0"
  @spec explain(query(), index(), document_id(), opts()) :: response()
  def explain(query, index, document_id, opts \\ []) do
    path = compose_indexed_path_suffix(index, "_explain", document_id)

    request(:post, path, query, opts)
  end

  @doc "Check `field_capabilities/3` for more information."
  @doc since: "1.5.0"
  @spec field_capabilities(binary() | [binary()]) :: response()
  def field_capabilities(fields) do
    fields_str = prepare_fields(fields)

    request(:get, "/_field_caps", nil, fields: fields_str)
  end

  @doc "Check `field_capabilities/3` for more information."
  @doc since: "1.5.0"
  def field_capabilities(fields, index_or_opts)

  @spec field_capabilities(fields, nil | index()) :: response() when fields: binary() | [binary()]
  def field_capabilities(fields, index) when is_name(index) do
    fields_str = prepare_fields(fields)
    path = compose_indexed_path_suffix(index, "_field_caps")

    request(:get, path, nil, fields: fields_str)
  end

  @spec field_capabilities(fields, opts()) :: response() when fields: binary() | [binary()]
  def field_capabilities(fields, opts) do
    fields_str = prepare_fields(fields)

    request(:get, "/_field_caps", nil, [{:fields, fields_str} | opts])
  end

  @doc """
  Allows you to retrieve the capabilities of fields among multiple indices. For data streams, the API returns field capabilities among the stream’s backing indices.

  The query parameter `fields` is provided via the first argument `fields`.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-field-caps.html#search-field-caps-api-query-params)
  for a detailed list of the parameters.
  """
  @doc since: "1.0.0"
  @spec field_capabilities(fields, nil | index(), opts()) :: response()
        when fields: binary() | [binary()]
  def field_capabilities(fields, index, opts) do
    fields_str = prepare_fields(fields)
    path = compose_indexed_path_suffix(index, "_field_caps")

    request(:get, path, nil, [{:fields, fields_str} | opts])
  end

  @doc "Check `profile/3` for more information."
  @doc since: "1.5.0"
  @spec profile(query()) :: response()
  def profile(query) do
    profile(query, nil, [])
  end

  @doc "Check `profile/3` for more information."
  @doc since: "1.5.0"
  def profile(query, index_or_opts)

  @spec profile(query(), nil | index()) :: response()
  def profile(query, index) when is_name(index) do
    profile(query, index, [])
  end

  @spec profile(query(), opts()) :: response()
  def profile(query, opts) do
    profile(query, nil, opts)
  end

  @doc """
  Provides detailed timing information about the execution of individual components in a search request.

  > #### Warning {: .warning}
  >
  > The Profile API is a debugging tool and adds significant overhead to search execution.
  """
  @doc since: "1.0.0"
  @spec profile(query(), nil | index(), opts()) :: response()
  def profile(query, index, opts) do
    query |> Map.put(:profile, true) |> search(index, opts)
  end

  @doc """
  Allows you to evaluate the quality of ranked search results over a set of typical search queries.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-rank-eval.html#search-rank-eval-api-query-params)
  for a detailed list of the parameters.
  """
  @doc since: "1.0.0"
  @spec rank_evaluation(map(), index(), opts()) :: response()
  def rank_evaluation(body, index, opts \\ []) when is_name!(index) do
    path = compose_indexed_path_suffix(index, "_rank_eval")

    request(:post, path, body, opts)
  end

  @doc """
  Returns the indices and shards that a search request would be executed against.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-shards.html#search-shards-api-query-params)
  for a detailed list of the parameters.
  """
  @doc since: "1.0.0"
  @spec search_shards(index(), opts()) :: response()
  def search_shards(index, opts \\ []) when is_name!(index) do
    path = compose_indexed_path_suffix(index, "_search_shards")

    request(:get, path, nil, opts)
  end

  @doc """
  Validates a potentially expensive query without executing it.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-validate.html#search-validate-api-query-params)
  for a detailed list of the parameters.
  """
  @doc since: "1.0.0"
  @spec validate(query(), nil | index(), opts()) :: response()
  def validate(query, index \\ nil, opts \\ []) when is_map(query) do
    path = compose_indexed_path_suffix(index, "_validate/query")

    request(:post, path, query, opts)
  end

  ## Public functions - Templates

  @doc "Check `search_template/3` for more information."
  @doc since: "1.5.0"
  @spec search_template(map()) :: response()
  def search_template(body) do
    search_template(body, nil, [])
  end

  @doc "Check `search_template/3` for more information."
  @doc since: "1.5.0"
  def search_template(body, index_or_opts)

  @spec search_template(map(), nil | index()) :: response()
  def search_template(body, index) when is_name(index) do
    search_template(body, index, [])
  end

  @spec search_template(map(), opts()) :: response()
  def search_template(body, opts) do
    search_template(body, nil, opts)
  end

  @doc """
  Runs a search with a [search template](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-template.html).

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-template-api.html#search-template-api-query-params)
  for a detailed list of the parameters.
  """
  @doc since: "1.0.0"
  @spec search_template(map(), nil | index(), opts()) :: response()
  def search_template(body, index, opts) do
    path = compose_indexed_path_suffix(index, "_search/template")

    request(:post, path, body, opts)
  end

  @doc "Check `multi_search_template/3` for more information."
  @doc since: "1.5.0"
  @spec multi_search_template(Enumerable.t()) :: response()
  def multi_search_template(body) do
    multi_search_template(body, nil, [])
  end

  @doc "Check `multi_search_template/3` for more information."
  @doc since: "1.5.0"
  def multi_search_template(body, index_or_opts)

  @spec multi_search_template(Enumerable.t(), nil | index()) :: response()
  def multi_search_template(body, index) when is_name(index) do
    multi_search_template(body, index, [])
  end

  @spec multi_search_template(Enumerable.t(), opts()) :: response()
  def multi_search_template(body, opts) do
    multi_search_template(body, nil, opts)
  end

  @doc """
  Runs multiple templated searches with a single request.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/multi-search-template.html#multi-search-template-api-query-params)
  for a detailed list of the parameters.
  """
  @doc since: "1.0.0"
  @spec multi_search_template(Enumerable.t(), nil | index(), opts()) :: response()
  def multi_search_template(body, index, opts) do
    queries = prepare_multi_search_template(body)
    path = compose_indexed_path_suffix(index, "_msearch/template")

    request(:post, path, queries, [{:ndjson, true} | opts])
  end

  @doc "Check `render_search_template/3` for more information."
  @doc since: "1.5.0"
  @spec render_search_template(map()) :: response()
  def render_search_template(body) do
    render_search_template(body, nil, [])
  end

  @doc "Check `render_search_template/3` for more information."
  @doc since: "1.5.0"
  def render_search_template(body, template_id_or_opts)

  @spec render_search_template(map(), nil | binary()) :: response()
  def render_search_template(body, template_id) when is_name(template_id) do
    render_search_template(body, template_id, [])
  end

  @spec render_search_template(map(), opts()) :: response()
  def render_search_template(body, opts) do
    render_search_template(body, nil, opts)
  end

  @doc """
  Renders a search template as a search request body.

  ### Request body

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/render-search-template-api.html#render-search-template-api-request-body)
  for a detailed list of the request body.
  """
  @doc since: "1.0.0"
  @spec render_search_template(map(), nil | binary(), opts()) :: response()
  def render_search_template(body, template_id, opts) do
    path = compose_indexed_path_prefix("_render/template", template_id)

    request(:post, path, body, opts)
  end

  ## Public functions - Geospatial

  @doc """
  Searches a vector tile for geospatial values. Returns results as a binary Mapbox vector tile.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-vector-tile-api.html#search-vector-tile-api-query-params)
  for a detailed list of the parameters.
  """
  @doc since: "1.0.0"
  @spec search_vector_tile(index(), atom() | binary(), integer(), integer(), integer(), opts()) ::
          response()
  def search_vector_tile(index, field, zoom, x, y, opts \\ [])
      when is_name!(index) and is_name!(field) and is_integer(zoom) and zoom in 0..29 and
             is_integer(x) and is_integer(y) do
    request(:get, "/#{index}/_mvt/#{field}/#{zoom}/#{x}/#{y}", nil, opts)
  end

  ## Private functions

  @spec prepare_fields(binary() | [binary()]) :: binary()
  defp prepare_fields(fields) do
    fields_str =
      cond do
        is_enum(fields) ->
          Enum.map_join(fields, ",", &to_string/1)

        is_binary(fields) ->
          fields

        true ->
          raise ArgumentError, "the argument `fields` must be a binary or a list of binaries"
      end

    if fields_str == "" do
      raise ArgumentError, "the argument `fields` cannot be an empty"
    end

    fields_str
  end

  @spec prepare_multi_search_template(Enumerable.t()) :: [map()]
  defp prepare_multi_search_template(body) do
    Enum.flat_map(body, fn
      {header, body} when is_map(header) and is_map(body) ->
        [header, body]

      body when is_map(body) ->
        [%{}, body]
    end)
  end
end
