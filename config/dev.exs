import Config

# Clear the terminal when running mix test.watch
config :mix_test_watch, clear: true

# Configure ElasticsearchEx
config :elasticsearch_ex,
  clusters: %{
    default: %{
      endpoint: "https://elastic:elastic@localhost:9200",
      req_opts: [connect_options: [transport_opts: [verify: :verify_none]]]
    }
  }
