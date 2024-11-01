defmodule ElasticsearchEx.ClientTest do
  use ElasticsearchEx.ConnCase

  alias ElasticsearchEx.Client

  @moduletag :capture_log

  # @my_headers %{"x-custom-header" => "Hello World!"}
  @my_body %{query: %{match_all: %{}}}

  @compressed_body @my_body |> Jason.encode!() |> :zlib.gzip()

  @resp_success %{
    "_shards" => %{"failed" => 0, "skipped" => 0, "successful" => 1, "total" => 1},
    "hits" => %{
      "hits" => [],
      "max_score" => nil,
      "total" => %{"relation" => "eq", "value" => 0}
    },
    "timed_out" => false,
    "took" => 2
  }

  @resp_error %{
    "error" => %{
      "index" => "my-index",
      "index_uuid" => "_na_",
      "reason" => "no such index [my-index]",
      "resource.id" => "my-index",
      "resource.type" => "index_or_alias",
      "root_cause" => [
        %{
          "index" => "my-index",
          "index_uuid" => "_na_",
          "reason" => "no such index [my-index]",
          "resource.id" => "my-index",
          "resource.type" => "index_or_alias",
          "type" => "index_not_found_exception"
        }
      ],
      "type" => "index_not_found_exception"
    },
    "status" => 404
  }

  describe "request/4" do
    import Client, only: [request: 4]

    test "returns okay when sucessful" do
      plug_fun = fn %Plug.Conn{method: "POST", request_path: "/my-index"} = conn ->
        {:ok, @compressed_body, conn} = Plug.Conn.read_body(conn)
        "a=b" = conn.query_string

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(@resp_success))
      end

      assert {:ok, @resp_success} =
               request(:post, "/my-index", @my_body, a: :b, req_opts: [plug: plug_fun])
    end

    test "returns okay when unsucessful" do
      plug_fun = fn %Plug.Conn{method: "POST", request_path: "/my-index"} = conn ->
        {:ok, @compressed_body, conn} = Plug.Conn.read_body(conn)
        "a=b" = conn.query_string

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(@resp_error["status"], Jason.encode!(@resp_error))
      end

      error = @resp_error["error"]

      assert {:error,
              %ElasticsearchEx.Error{
                reason: error["reason"],
                root_cause: error["root_cause"],
                status: @resp_error["status"],
                type: error["type"],
                original: error
              }} == request(:post, "/my-index", @my_body, a: :b, req_opts: [plug: plug_fun])
    end
  end
end
