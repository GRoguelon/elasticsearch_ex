defmodule ElasticsearchEx.ClientTest do
  use ElasticsearchEx.ConnCase

  alias ElasticsearchEx.Client

  @moduletag :capture_log

  @my_headers %{"x-custom-header" => "Hello World!"}
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

  describe "head/1" do
    test "returns okay when sucessful" do
      plug_fun = fn %Plug.Conn{method: "HEAD", request_path: "/my-index"} = conn ->
        Plug.Conn.resp(conn, 200, "")
      end

      assert :ok = Client.head("/my-index", nil, req_opts: [plug: plug_fun])
    end

    test "returns an error when unsucessful" do
      plug_fun = fn %Plug.Conn{method: "HEAD", request_path: "/my-index"} = conn ->
        Plug.Conn.resp(conn, 400, "")
      end

      assert :error = Client.head("/my-index", nil, req_opts: [plug: plug_fun])
    end
  end

  describe "head/2 with headers" do
    setup do
      {response, status} = Enum.random(ok: 200, error: 400)

      {:ok, response: response, status: status}
    end

    test "returns okay when sucessful", %{response: response, status: status} do
      plug_fun = fn %Plug.Conn{method: "HEAD", request_path: "/my-index"} = conn ->
        ["Hello World!"] = Plug.Conn.get_req_header(conn, "x-custom-header")

        Plug.Conn.resp(conn, status, "")
      end

      assert ^response = Client.head("/my-index", @my_headers, req_opts: [plug: plug_fun])
    end
  end

  describe "head/3 with headers and options" do
    setup do
      {response, status} = Enum.random(ok: 200, error: 400)

      {:ok, response: response, status: status}
    end

    test "returns okay when sucessful", %{response: response, status: status} do
      plug_fun = fn %Plug.Conn{method: "HEAD", request_path: "/my-index", query_string: "a=b"} =
                      conn ->
        ["Hello World!"] = Plug.Conn.get_req_header(conn, "x-custom-header")

        Plug.Conn.resp(conn, status, "")
      end

      assert ^response = Client.head("/my-index", @my_headers, a: :b, req_opts: [plug: plug_fun])
    end
  end

  describe "get/1" do
    test "returns okay when sucessful" do
      plug_fun = fn %Plug.Conn{method: "GET", request_path: "/my-index"} = conn ->
        Plug.Conn.resp(conn, 200, "")
      end

      assert {:ok, nil} = Client.get("/my-index", nil, nil, req_opts: [plug: plug_fun])
    end

    test "returns an error when unsucessful" do
      plug_fun = fn %Plug.Conn{method: "GET", request_path: "/my-index"} = conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(@resp_error["status"], Jason.encode!(@resp_error))
      end

      error = @resp_error["error"]

      assert {
               :error,
               %ElasticsearchEx.Error{
                 reason: error["reason"],
                 root_cause: error["root_cause"],
                 status: @resp_error["status"],
                 type: error["type"],
                 original: error
               }
             } == Client.get("/my-index", nil, nil, req_opts: [plug: plug_fun])
    end
  end

  describe "get/2 with headers" do
    test "returns okay when sucessful" do
      plug_fun = fn %Plug.Conn{method: "GET", request_path: "/my-index"} = conn ->
        ["Hello World!"] = Plug.Conn.get_req_header(conn, "x-custom-header")
        {:ok, "", conn} = Plug.Conn.read_body(conn)

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(@resp_success))
      end

      assert {:ok, @resp_success} =
               Client.get("/my-index", @my_headers, nil, req_opts: [plug: plug_fun])
    end

    test "returns okay when unsucessful" do
      plug_fun = fn %Plug.Conn{method: "GET", request_path: "/my-index"} = conn ->
        ["Hello World!"] = Plug.Conn.get_req_header(conn, "x-custom-header")
        {:ok, "", conn} = Plug.Conn.read_body(conn)

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
              }} == Client.get("/my-index", @my_headers, nil, req_opts: [plug: plug_fun])
    end
  end

  describe "get/3 with body" do
    test "returns okay when sucessful" do
      plug_fun = fn %Plug.Conn{method: "GET", request_path: "/my-index"} = conn ->
        {:ok, @compressed_body, conn} = Plug.Conn.read_body(conn)

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(@resp_success))
      end

      assert {:ok, @resp_success} =
               Client.get("/my-index", nil, @my_body, req_opts: [plug: plug_fun])
    end

    test "returns okay when unsucessful" do
      plug_fun = fn %Plug.Conn{method: "GET", request_path: "/my-index"} = conn ->
        {:ok, @compressed_body, conn} = Plug.Conn.read_body(conn)

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
              }} == Client.get("/my-index", nil, @my_body, req_opts: [plug: plug_fun])
    end
  end

  describe "get/4 with options" do
    test "returns okay when sucessful" do
      plug_fun = fn %Plug.Conn{method: "GET", request_path: "/my-index"} = conn ->
        "a=b" = conn.query_string

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(@resp_success))
      end

      assert {:ok, @resp_success} =
               Client.get("/my-index", nil, nil, a: :b, req_opts: [plug: plug_fun])
    end

    test "returns okay when unsucessful" do
      plug_fun = fn %Plug.Conn{method: "GET", request_path: "/my-index"} = conn ->
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
              }} == Client.get("/my-index", nil, nil, a: :b, req_opts: [plug: plug_fun])
    end
  end

  describe "post/1" do
    test "returns okay when sucessful" do
      plug_fun = fn %Plug.Conn{method: "POST", request_path: "/my-index"} = conn ->
        {:ok, @compressed_body, conn} = Plug.Conn.read_body(conn)

        Plug.Conn.resp(conn, 200, "")
      end

      assert {:ok, nil} = Client.post("/my-index", nil, @my_body, req_opts: [plug: plug_fun])
    end

    test "returns an error when unsucessful" do
      plug_fun = fn %Plug.Conn{method: "POST", request_path: "/my-index"} = conn ->
        {:ok, @compressed_body, conn} = Plug.Conn.read_body(conn)

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(@resp_error["status"], Jason.encode!(@resp_error))
      end

      error = @resp_error["error"]

      assert {
               :error,
               %ElasticsearchEx.Error{
                 reason: error["reason"],
                 root_cause: error["root_cause"],
                 status: @resp_error["status"],
                 type: error["type"],
                 original: error
               }
             } == Client.post("/my-index", nil, @my_body, req_opts: [plug: plug_fun])
    end
  end

  describe "post/2 with headers" do
    setup do
      {:ok, my_headers: Map.merge(@my_headers, %{"content-type" => "application/json"})}
    end

    test "returns okay when sucessful", %{my_headers: my_headers} do
      plug_fun = fn %Plug.Conn{method: "POST", request_path: "/my-index"} = conn ->
        ["Hello World!"] = Plug.Conn.get_req_header(conn, "x-custom-header")
        {:ok, @compressed_body, conn} = Plug.Conn.read_body(conn)

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(@resp_success))
      end

      assert {:ok, @resp_success} =
               Client.post("/my-index", my_headers, @my_body, req_opts: [plug: plug_fun])
    end

    test "returns okay when unsucessful", %{my_headers: my_headers} do
      plug_fun = fn %Plug.Conn{method: "POST", request_path: "/my-index"} = conn ->
        ["Hello World!"] = Plug.Conn.get_req_header(conn, "x-custom-header")
        {:ok, @compressed_body, conn} = Plug.Conn.read_body(conn)

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
              }} == Client.post("/my-index", my_headers, @my_body, req_opts: [plug: plug_fun])
    end
  end

  describe "post/3 with body" do
    test "returns okay when sucessful" do
      plug_fun = fn %Plug.Conn{method: "POST", request_path: "/my-index"} = conn ->
        {:ok, @compressed_body, conn} = Plug.Conn.read_body(conn)

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(@resp_success))
      end

      assert {:ok, @resp_success} =
               Client.post("/my-index", nil, @my_body, req_opts: [plug: plug_fun])
    end

    test "returns okay when unsucessful" do
      plug_fun = fn %Plug.Conn{method: "POST", request_path: "/my-index"} = conn ->
        {:ok, @compressed_body, conn} = Plug.Conn.read_body(conn)

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
              }} == Client.post("/my-index", nil, @my_body, req_opts: [plug: plug_fun])
    end
  end

  describe "post/4 with options" do
    test "returns okay when sucessful" do
      plug_fun = fn %Plug.Conn{method: "POST", request_path: "/my-index"} = conn ->
        {:ok, @compressed_body, conn} = Plug.Conn.read_body(conn)
        "a=b" = conn.query_string

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(@resp_success))
      end

      assert {:ok, @resp_success} =
               Client.post("/my-index", nil, @my_body, a: :b, req_opts: [plug: plug_fun])
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
              }} == Client.post("/my-index", nil, @my_body, a: :b, req_opts: [plug: plug_fun])
    end
  end

  describe "put/1" do
    test "returns okay when sucessful" do
      plug_fun = fn %Plug.Conn{method: "PUT", request_path: "/my-index"} = conn ->
        {:ok, @compressed_body, conn} = Plug.Conn.read_body(conn)

        Plug.Conn.resp(conn, 200, "")
      end

      assert {:ok, nil} = Client.put("/my-index", nil, @my_body, req_opts: [plug: plug_fun])
    end

    test "returns an error when unsucessful" do
      plug_fun = fn %Plug.Conn{method: "PUT", request_path: "/my-index"} = conn ->
        {:ok, @compressed_body, conn} = Plug.Conn.read_body(conn)

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(@resp_error["status"], Jason.encode!(@resp_error))
      end

      error = @resp_error["error"]

      assert {
               :error,
               %ElasticsearchEx.Error{
                 reason: error["reason"],
                 root_cause: error["root_cause"],
                 status: @resp_error["status"],
                 type: error["type"],
                 original: error
               }
             } == Client.put("/my-index", nil, @my_body, req_opts: [plug: plug_fun])
    end
  end

  describe "put/2 with headers" do
    setup do
      {:ok, my_headers: Map.merge(@my_headers, %{"content-type" => "application/json"})}
    end

    test "returns okay when sucessful", %{my_headers: my_headers} do
      plug_fun = fn %Plug.Conn{method: "PUT", request_path: "/my-index"} = conn ->
        ["Hello World!"] = Plug.Conn.get_req_header(conn, "x-custom-header")
        {:ok, @compressed_body, conn} = Plug.Conn.read_body(conn)

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(@resp_success))
      end

      assert {:ok, @resp_success} =
               Client.put("/my-index", my_headers, @my_body, req_opts: [plug: plug_fun])
    end

    test "returns okay when unsucessful", %{my_headers: my_headers} do
      plug_fun = fn %Plug.Conn{method: "PUT", request_path: "/my-index"} = conn ->
        ["Hello World!"] = Plug.Conn.get_req_header(conn, "x-custom-header")
        {:ok, @compressed_body, conn} = Plug.Conn.read_body(conn)

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
              }} == Client.put("/my-index", my_headers, @my_body, req_opts: [plug: plug_fun])
    end
  end

  describe "put/3 with body" do
    test "returns okay when sucessful" do
      plug_fun = fn %Plug.Conn{method: "PUT", request_path: "/my-index"} = conn ->
        {:ok, @compressed_body, conn} = Plug.Conn.read_body(conn)

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(@resp_success))
      end

      assert {:ok, @resp_success} =
               Client.put("/my-index", nil, @my_body, req_opts: [plug: plug_fun])
    end

    test "returns okay when unsucessful" do
      plug_fun = fn %Plug.Conn{method: "PUT", request_path: "/my-index"} = conn ->
        {:ok, @compressed_body, conn} = Plug.Conn.read_body(conn)

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
              }} == Client.put("/my-index", nil, @my_body, req_opts: [plug: plug_fun])
    end
  end

  describe "put/4 with options" do
    test "returns okay when sucessful" do
      plug_fun = fn %Plug.Conn{method: "PUT", request_path: "/my-index"} = conn ->
        {:ok, @compressed_body, conn} = Plug.Conn.read_body(conn)
        "a=b" = conn.query_string

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(@resp_success))
      end

      assert {:ok, @resp_success} =
               Client.put("/my-index", nil, @my_body, a: :b, req_opts: [plug: plug_fun])
    end

    test "returns okay when unsucessful" do
      plug_fun = fn %Plug.Conn{method: "PUT", request_path: "/my-index"} = conn ->
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
              }} == Client.put("/my-index", nil, @my_body, a: :b, req_opts: [plug: plug_fun])
    end
  end

  describe "delete/1" do
    test "returns okay when sucessful" do
      plug_fun = fn %Plug.Conn{method: "DELETE", request_path: "/my-index"} = conn ->
        {:ok, @compressed_body, conn} = Plug.Conn.read_body(conn)

        Plug.Conn.resp(conn, 200, "")
      end

      assert {:ok, nil} = Client.delete("/my-index", nil, @my_body, req_opts: [plug: plug_fun])
    end

    test "returns an error when unsucessful" do
      plug_fun = fn %Plug.Conn{method: "DELETE", request_path: "/my-index"} = conn ->
        {:ok, @compressed_body, conn} = Plug.Conn.read_body(conn)

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(@resp_error["status"], Jason.encode!(@resp_error))
      end

      error = @resp_error["error"]

      assert {
               :error,
               %ElasticsearchEx.Error{
                 reason: error["reason"],
                 root_cause: error["root_cause"],
                 status: @resp_error["status"],
                 type: error["type"],
                 original: error
               }
             } == Client.delete("/my-index", nil, @my_body, req_opts: [plug: plug_fun])
    end
  end

  describe "delete/2 with headers" do
    setup do
      {:ok, my_headers: Map.merge(@my_headers, %{"content-type" => "application/json"})}
    end

    test "returns okay when sucessful", %{my_headers: my_headers} do
      plug_fun = fn %Plug.Conn{method: "DELETE", request_path: "/my-index"} = conn ->
        ["Hello World!"] = Plug.Conn.get_req_header(conn, "x-custom-header")
        {:ok, @compressed_body, conn} = Plug.Conn.read_body(conn)

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(@resp_success))
      end

      assert {:ok, @resp_success} =
               Client.delete("/my-index", my_headers, @my_body, req_opts: [plug: plug_fun])
    end

    test "returns okay when unsucessful", %{my_headers: my_headers} do
      plug_fun = fn %Plug.Conn{method: "DELETE", request_path: "/my-index"} = conn ->
        ["Hello World!"] = Plug.Conn.get_req_header(conn, "x-custom-header")
        {:ok, @compressed_body, conn} = Plug.Conn.read_body(conn)

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
              }} == Client.delete("/my-index", my_headers, @my_body, req_opts: [plug: plug_fun])
    end
  end

  describe "delete/3 with body" do
    test "returns okay when sucessful" do
      plug_fun = fn %Plug.Conn{method: "DELETE", request_path: "/my-index"} = conn ->
        {:ok, @compressed_body, conn} = Plug.Conn.read_body(conn)

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(@resp_success))
      end

      assert {:ok, @resp_success} =
               Client.delete("/my-index", nil, @my_body, req_opts: [plug: plug_fun])
    end

    test "returns okay when unsucessful" do
      plug_fun = fn %Plug.Conn{method: "DELETE", request_path: "/my-index"} = conn ->
        {:ok, @compressed_body, conn} = Plug.Conn.read_body(conn)

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
              }} == Client.delete("/my-index", nil, @my_body, req_opts: [plug: plug_fun])
    end
  end

  describe "delete/4 with options" do
    test "returns okay when sucessful" do
      plug_fun = fn %Plug.Conn{method: "DELETE", request_path: "/my-index"} = conn ->
        {:ok, @compressed_body, conn} = Plug.Conn.read_body(conn)
        "a=b" = conn.query_string

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(@resp_success))
      end

      assert {:ok, @resp_success} =
               Client.delete("/my-index", nil, @my_body, a: :b, req_opts: [plug: plug_fun])
    end

    test "returns okay when unsucessful" do
      plug_fun = fn %Plug.Conn{method: "DELETE", request_path: "/my-index"} = conn ->
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
              }} == Client.delete("/my-index", nil, @my_body, a: :b, req_opts: [plug: plug_fun])
    end
  end
end
