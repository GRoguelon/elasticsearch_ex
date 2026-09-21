# Elasticsearch

> ⚠️ **This project is deprecated and no longer maintained.**
>
> `elasticsearch_ex` will not receive further updates, including bug fixes
> and security patches. If you're starting a new project or maintaining an
> existing one, please migrate to
> [`dowser_elasticsearch`](https://hex.pm/packages/dowser_elasticsearch)
> ([docs](https://hexdocs.pm/dowser_elasticsearch)) instead.

`elasticsearch_ex` allows to interact with [Elasticsearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html) cluster.

## Installation

```elixir
def deps do
  [
    {:elasticsearch_ex, "~> 1.9"}
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
      req_opts: [connect_options: [transport_opts: [verify: :verify_none]]]
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
