defmodule ElasticsearchEx.Error do
  @moduledoc """
  Wraps the HTTP error into an Elixir exception.
  """

  defexception [:status, :index, :index_uuid, :reason, :root_cause, :type]

  ## Typespecs

  @type t :: %__MODULE__{
          __exception__: true,
          status: nil | 300..599,
          index: nil | binary(),
          index_uuid: nil | binary(),
          reason: nil | binary(),
          root_cause: nil | [map()],
          type: nil | binary()
        }

  ## Public functions

  @impl true
  @spec exception(AnyHttp.Response.t()) :: t()
  def exception(%AnyHttp.Response{status: status, body: %{"error" => error}}) do
    %__MODULE__{
      status: status,
      index: error["index"],
      index_uuid: error["index_uuid"],
      reason: error["reason"],
      root_cause: error["root_cause"],
      type: error["type"]
    }
  end

  @impl true
  @spec message(t()) :: binary()
  def message(%__MODULE__{reason: reason}) do
    reason
  end
end
