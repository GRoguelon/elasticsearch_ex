import Config

# Configure ElasticsearchEx
config :elasticsearch_ex,
  clusters: %{
    default: %{
      endpoint: "https://elastic:elastic@localhost:9200",
      req_opts: [connect_options: [transport_opts: [verify: :verify_none]]]
    }
  }
