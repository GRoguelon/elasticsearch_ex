defmodule ElasticsearchEx.Error do
  @moduledoc """
  Wraps the HTTP error into an Elixir exception.
  """

  @derive {Inspect, only: [:status, :reason, :root_cause, :type]}
  defexception [:status, :reason, :root_cause, :type, :original]

  ## Typespecs

  @type t :: %__MODULE__{
          __exception__: true,
          status: nil | 300..599,
          reason: nil | binary(),
          root_cause: nil | [map()],
          type: nil | binary()
        }

  ## Public functions

  @impl true
  @spec exception(Req.Response.t()) :: t()
  def exception(%Req.Response{status: status, body: nil}) do
    %__MODULE__{status: status, reason: "Response returned #{status} status code"}
  end

  @impl true
  def exception(%Req.Response{status: status, body: %{"error" => error}}) do
    %__MODULE__{
      status: status,
      reason: error["reason"],
      root_cause: error["root_cause"],
      type: error["type"],
      original: error
    }
  end

  @impl true
  def exception(%Req.Response{
        status: 404,
        body: %{"_id" => doc_id, "result" => "not_found"} = body
      }) do
    %__MODULE__{
      status: 404,
      reason: "Document with ID: `#{doc_id}` not found",
      root_cause: nil,
      type: "not_found",
      original: body
    }
  end

  @impl true
  @spec message(t()) :: binary()
  def message(%__MODULE__{reason: reason}) do
    reason
  end
end
