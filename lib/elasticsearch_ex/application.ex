defmodule ElasticsearchEx.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    :erlang.system_flag(:backtrace_depth, 20)

    children = [
      # Starts a worker by calling: ElasticsearchEx.Worker.start_link(arg)
      # {ElasticsearchEx.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ElasticsearchEx.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
