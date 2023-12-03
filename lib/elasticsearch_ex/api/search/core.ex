defmodule ElasticsearchEx.Api.Search.Core do
  @moduledoc """
  Search APIs are used to search and aggregate data stored in Elasticsearch indices and data streams. For an overview and related tutorials, see [The search API](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-your-data.html).

  Most search APIs support [multi-target syntax](https://www.elastic.co/guide/en/elasticsearch/reference/current/api-conventions.html#api-multi-index), with the exception of the [explain API](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-explain.html).
  """

  ## Module attributes

  @default_headers %{content_type: "application/json"}

  @default_url "https://localhost:9200"

  ## Typespecs

  @typedoc "Represents the response from Elasticsearch."
  @type response :: {:ok, Req.Response.t()} | {:error, Exception.t()}

  @typedoc "Represents the body expected by the search API."
  @type search_body :: map()

  @typedoc "The possible individual options accepted by the search function.s"
  @type search_opt :: {:http_method, :get | :post} | {:url, binary() | Req.Request.t()}

  @typedoc "The possible options accepted by the search function.s"
  @type search_opts :: [search_opt()]

  ## Public functions

  @doc """
  Returns search hits that match the query defined in the request.

  It expects the first argument to be a valid Elasticsearch query represented by an Elixir `Map`.

  ### Options

  * `url`: The string URL of the cluster or a `Req.Request` struct, defaults to
  `http://localhost:9200/_search`
  * `http_method`: The HTTP method used by the query, can be: `:post` (default) or `:get`

  ### Examples

      iex> url = Req.new(
      ...>   url: "https://localhost:9200/_search",
      ...>   auth: {:basic, "elastic:elastic"},
      ...>   connect_options: [transport_opts: [verify: :verify_none]]
      ...> )
      ...>
      ...> ElasticsearchEx.Api.Search.Core.search(%{query: %{match_all: %{}}, size: 1}, url: url)
      {:ok,
       %Req.Response{
         status: 200,
         headers: %{
           "content-type" => ["application/json"],
           "transfer-encoding" => ["chunked"],
           "x-elastic-product" => ["Elasticsearch"]
         },
         body: %{
           "_shards" => %{
             "failed" => 0,
             "skipped" => 0,
             "successful" => 0,
             "total" => 0
           },
           "hits" => %{
             "hits" => [],
             "max_score" => 0.0,
             "total" => %{"relation" => "eq", "value" => 0}
           },
           "timed_out" => false,
           "took" => 9
         },
         trailers: %{},
         private: %{}
       }}
  """
  @spec search(search_body(), search_opts()) :: response()
  def search(query, opts \\ []) when is_map(query) and is_list(opts) do
    method = Keyword.get(opts, :http_method, :post)
    url = Keyword.get(opts, :url, "#{@default_url}/_search")

    Req.request(url, method: method, headers: @default_headers, json: query)
  end
end
