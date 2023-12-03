# Elasticsearch

`elasticsearch_ex` allows to interact with [Elasticsearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html) cluster.

## Installation

```elixir
def deps do
  [
    {:elasticsearch_ex, "~> 0.2.0"}
  ]
end
```

Documentation can be found at https://hexdocs.pm/elasticsearch_ex.

## Usage

### Search

Request:
```elixir
url = Req.new(
  url: "https://localhost:9200/_search",
  auth: {:basic, "elastic:elastic"},
  connect_options: [transport_opts: [verify: :verify_none]]
)

ElasticsearchEx.Api.Search.Core.search(%{query: %{match_all: %{}}, size: 1}, url: url)
```

Response:
```elixir
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
     "took" => 2
   },
   trailers: %{},
   private: %{}
 }}
```

You can also change the HTTP method used by specifying the options `http_method: :get` when calling the function `search/2`.

```elixir
ElasticsearchEx.Api.Search.Core.search(%{query: %{match_all: %{}}, size: 1},
  url: url,
  http_method: :get
)
```
