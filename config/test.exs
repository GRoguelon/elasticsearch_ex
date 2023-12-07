import Config

# Define default any_http client adapter
config :any_http, client_adapter: AnyHttp.Adapters.Httpc

config :elasticsearch_ex, url: "http://elastic:elastic@localhost:62421"
