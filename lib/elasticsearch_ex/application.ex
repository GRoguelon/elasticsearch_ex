defmodule ElasticsearchEx.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @prod? Mix.env() == :prod

  @impl true
  def start(_type, _args) do
    :erlang.system_flag(:backtrace_depth, 20)

    children = [
      {ElasticsearchEx.MappingsCacher,
       [
         time_to_live: Application.get_env(:elasticsearch_ex, :time_to_live),
         lazy: Application.get_env(:elasticsearch_ex, :lazy, not @prod?)
       ]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ElasticsearchEx.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
