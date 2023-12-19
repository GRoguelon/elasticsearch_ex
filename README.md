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

### Configure your cluster

```elixir
config :elasticsearch_ex, url: "https://elastic:elastic@localhost:9200"
```

### Search your cluster

You can easily query your local Elasticsearch with:
```elixir
ElasticsearchEx.Api.Search.Core.search(%{query: %{match_all: %{}}, size: 1}, http_opts: [ssl: [verify: :verify_none]])
```

Response:
```elixir
{:ok,
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
         "_id" => "8uaORIwBU7w6JJjTX-8-",
         "_index" => "my_index",
         "_score" => 1.0,
         "_source" => %{
           ...
         }
       }
     ],
     "max_score" => 1.0,
     "total" => %{"relation" => "eq", "value" => 3}
   },
   "timed_out" => false,
   "took" => 7
 }}
```
