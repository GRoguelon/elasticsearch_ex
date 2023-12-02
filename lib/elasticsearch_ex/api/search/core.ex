defmodule ElasticsearchEx.Api.Search.Core do
  @moduledoc """
  Search APIs are used to search and aggregate data stored in Elasticsearch indices and data streams. For an overview and related tutorials, see [The search API](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-your-data.html).

  Most search APIs support [multi-target syntax](https://www.elastic.co/guide/en/elasticsearch/reference/current/api-conventions.html#api-multi-index), with the exception of the [explain API](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-explain.html).
  """

  @default_headers %{content_type: "application/json"}

  @doc """
  Returns search hits that match the query defined in the request.

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
  @spec search(map(), keyword()) :: {:ok, Req.Response.t()} | {:error, Exception.t()}
  def search(query, opts \\ []) when is_map(query) and is_list(opts) do
    method = Keyword.get(opts, :http_method, :post)
    url = Keyword.fetch!(opts, :url)

    Req.request(url, method: method, headers: @default_headers, json: query)
  end
end
