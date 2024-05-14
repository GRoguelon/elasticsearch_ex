# Elasticsearch

> [!WARNING]
> The library is still unstable and the API might be broken with the next releases.

`elasticsearch_ex` allows to interact with [Elasticsearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html) cluster.

## Installation

```elixir
def deps do
  [
    {:elasticsearch_ex, "~> 1.5"}
  ]
end
```

Documentation can be found at https://hexdocs.pm/elasticsearch_ex.

## Usage

### Configure your cluster

```elixir
# Configure ElasticsearchEx
config :elasticsearch_ex,
  clusters: %{
    default: %{
      endpoint: "https://elastic:elastic@localhost:9200",
      # For development only, if not specified, SSL is configured for you.
      req_opts: [ssl: [verify: :verify_none]]
    }
  }
```

### Index a document

```elixir
ElasticsearchEx.index(%{message: "Hello World!"}, "my-index")
```

### Search your cluster

You can easily query your local Elasticsearch with:
```elixir
ElasticsearchEx.search(%{query: %{match_all: %{}}, size: 1}, "my-index")
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
         "_index" => "my-index",
         "_score" => 1.0,
         "_source" => %{
           "message" => "Hello World!"
         }
       }
     ],
     "max_score" => 1.0,
     "total" => %{"relation" => "eq", "value" => 1}
   },
   "timed_out" => false,
   "took" => 7
 }}
```
