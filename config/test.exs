import Config

# Define default any_http client adapter
config :any_http, client_adapter: AnyHttp.Adapters.Httpc

# Configure ElasticsearchEx
config :elasticsearch_ex,
  clusters: %{
    default: %{
      endpoint: "https://elastic:elastic@localhost:9200",
      http_opts: [ssl: [verify: :verify_none]]
    }
  }
