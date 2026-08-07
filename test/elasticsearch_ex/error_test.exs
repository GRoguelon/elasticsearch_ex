defmodule ElasticsearchEx.ErrorTest do
  use ExUnit.Case, async: true

  alias ElasticsearchEx.Error

  @reason "Invalid request"
  @error_type "invalid_request"
  @root_cause [%{"attribute" => "body"}]

  @error %{"reason" => @reason, "type" => @error_type, "root_cause" => @root_cause}

  setup_all do
    response = %Req.Response{status: 400, body: %{"error" => @error}}

    {:ok, response: response}
  end

  test "module is an exception" do
    behaviours = Error.__info__(:attributes) |> Keyword.fetch!(:behaviour)

    assert Exception in behaviours
  end

  describe "callback exception/1" do
    test "accepts a Req.Response argument and returns an error", %{response: response} do
      assert %Error{
               status: 400,
               reason: @reason,
               type: @error_type,
               root_cause: @root_cause,
               original: @error
             } = Error.exception(response)
    end
  end

  describe "callback exception/1 without an error body" do
    test "accepts a plain text body" do
      response = %Req.Response{status: 502, body: "Bad Gateway"}

      assert %Error{status: 502, reason: "Response returned 502 status code"} =
               Error.exception(response)
    end

    test "accepts a JSON body without an error key" do
      body = %{"took" => 3, "timed_out" => false, "failures" => [%{"status" => 409}]}
      response = %Req.Response{status: 409, body: body}

      assert %Error{status: 409, reason: "Response returned 409 status code", original: ^body} =
               Error.exception(response)
    end
  end

  describe "callback message/1" do
    test "accepts a Req.Response argument and returns an error", %{response: response} do
      error = Error.exception(response)

      assert @reason = Error.message(error)
    end
  end
end
