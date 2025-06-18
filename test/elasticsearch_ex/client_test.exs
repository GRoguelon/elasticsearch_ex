defmodule ElasticsearchEx.ClientTest do
  use ElasticsearchEx.ConnCase, async: false

  alias ElasticsearchEx.Client

  @moduletag :capture_log

  # Sample response bodies
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

  @my_body %{"query" => %{"match_all" => %{}}}
  @compressed_body @my_body |> Jason.encode!() |> :zlib.gzip()

  setup do
    clusters = Application.get_env(:elasticsearch_ex, :clusters)

    # Set up application config
    Application.put_env(:elasticsearch_ex, :clusters, %{
      default: %{
        endpoint: "http://localhost:9200",
        headers: %{"x-test" => "test"},
        req_opts: [plug: {Req.Test, ElasticsearchEx.ClientStub}]
      },
      custom: %{
        endpoint: "http://custom:9200",
        headers: %{"x-custom" => "custom"},
        req_opts: [plug: {Req.Test, ElasticsearchEx.ClientStub}]
      }
    })

    on_exit(fn -> Application.put_env(:elasticsearch_ex, :clusters, clusters) end)

    :ok
  end

  describe "request/4" do
    import Client, only: [request: 3, request: 4]

    test "returns ok for successful POST request with JSON body" do
      Req.Test.stub(ElasticsearchEx.ClientStub, fn
        %Plug.Conn{method: "POST", request_path: "/my-index/_search"} = conn ->
          {:ok, @compressed_body, conn} = Plug.Conn.read_body(conn)
          assert conn.query_string == "q=test"
          assert conn |> Plug.Conn.get_req_header("content-type") == ["application/json"]
          assert conn |> Plug.Conn.get_req_header("x-test") == ["test"]

          Req.Test.json(conn, @resp_success)
      end)

      assert {:ok, @resp_success} = request(:post, "/my-index/_search", @my_body, q: :test)
    end

    test "returns error for unsuccessful POST request" do
      Req.Test.stub(ElasticsearchEx.ClientStub, fn
        %Plug.Conn{method: "POST", request_path: "/my-index/_search"} = conn ->
          {:ok, @compressed_body, conn} = Plug.Conn.read_body(conn)
          assert conn.query_string == "q=test"

          Req.Test.json(conn, @resp_error)
      end)

      error = @resp_error["error"]

      assert {:error,
              %ElasticsearchEx.Error{
                reason: error["reason"],
                root_cause: error["root_cause"],
                status: @resp_error["status"],
                type: error["type"],
                original: error
              }} ==
               request(:post, "/my-index/_search", @my_body, q: :test)
    end

    test "handles GET request with no body" do
      Req.Test.stub(ElasticsearchEx.ClientStub, fn
        %Plug.Conn{method: "GET", request_path: "/my-index/_mapping"} = conn ->
          assert conn.query_string == ""
          assert conn |> Plug.Conn.get_req_header("content-type") == ["application/json"]
          assert conn |> Plug.Conn.get_req_header("x-test") == ["test"]

          Req.Test.json(conn, %{"my-index" => %{"mappings" => %{}}})
      end)

      assert {:ok, %{"my-index" => %{"mappings" => %{}}}} =
               request(:get, "/my-index/_mapping", nil)
    end

    test "handles NDJSON request" do
      ndjson_body = [%{"index" => %{"_index" => "my-index"}}, %{"field" => "value"}]
      compressed_ndjson = ndjson_body |> ElasticsearchEx.Ndjson.encode!() |> :zlib.gzip()

      Req.Test.stub(ElasticsearchEx.ClientStub, fn
        %Plug.Conn{method: "POST", request_path: "/_bulk"} = conn ->
          {:ok, ^compressed_ndjson, conn} = Plug.Conn.read_body(conn)
          assert Plug.Conn.get_req_header(conn, "content-type") == ["application/x-ndjson"]

          Req.Test.json(conn, %{"items" => []})
      end)

      assert {:ok, %{"items" => []}} = request(:post, "/_bulk", ndjson_body, ndjson: true)
    end

    test "uses custom cluster configuration" do
      Req.Test.stub(ElasticsearchEx.ClientStub, fn
        %Plug.Conn{method: "GET", request_path: "/my-index/_doc/1"} = conn ->
          assert conn |> Plug.Conn.get_req_header("x-other") == ["other"]

          Req.Test.json(conn, @resp_success)
      end)

      opts = [
        cluster: %{endpoint: "http://other:9200", headers: %{"x-other" => "other"}},
        req_opts: [plug: {Req.Test, ElasticsearchEx.ClientStub}]
      ]

      assert {:ok, @resp_success} = request(:get, "/my-index/_doc/1", nil, opts)
    end

    test "uses named cluster from application config" do
      Req.Test.stub(ElasticsearchEx.ClientStub, fn
        %Plug.Conn{method: "GET", request_path: "/my-index/_doc/1"} = conn ->
          assert conn |> Plug.Conn.get_req_header("x-custom") == ["custom"]

          Req.Test.json(conn, @resp_success)
      end)

      assert {:ok, @resp_success} = request(:get, "/my-index/_doc/1", nil, cluster: :custom)
    end

    test "deserializes response with :deserialize option" do
      document = %{"_index" => "my-index", "_source" => %{"field" => "value"}}
      cache_pid = Process.whereis(ElasticsearchEx.MappingsCacher)

      Req.Test.stub(ElasticsearchEx.ClientStub, fn
        %Plug.Conn{method: "GET", request_path: "/my-index/_mapping"} = conn ->
          Req.Test.json(conn, %{
            "my-index" => %{"mappings" => %{"properties" => %{"field" => %{"type" => "text"}}}}
          })

        %Plug.Conn{method: "GET", request_path: "/my-index/_doc/1"} = conn ->
          Req.Test.json(conn, document)
      end)

      Req.Test.allow(ElasticsearchEx.ClientStub, self(), cache_pid)

      assert {:ok, ^document} = request(:get, "/my-index/_doc/1", nil, deserialize: true)
    end

    test "converts keys to atoms with :keys option" do
      document = %{"_index" => "my-index", "_source" => %{"field" => "value"}}

      Req.Test.stub(ElasticsearchEx.ClientStub, fn
        %Plug.Conn{method: "GET", request_path: "/my-index/_doc/1"} = conn ->
          Req.Test.json(conn, document)
      end)

      assert {:ok, response} =
               request(:get, "/my-index/_doc/1", nil, keys_as_atoms: true)

      assert response == ElasticsearchEx.MapExt.atomize_keys(document)
    end

    test "raises for invalid cluster configuration" do
      Req.Test.stub(ElasticsearchEx.ClientStub, fn conn -> Req.Test.json(conn, @resp_success) end)

      assert_raise RuntimeError, "unable to find the cluster configuration", fn ->
        request(:get, "/my-index/_search", nil, cluster: :invalid)
      end
    end

    test "raises for conflicting req_opts and deserialize/keys" do
      Req.Test.stub(ElasticsearchEx.ClientStub, fn conn -> Req.Test.json(conn, @resp_success) end)

      opts = [req_opts: [decode_json: [keys: :atoms]], deserialize: true]

      assert_raise ArgumentError, ~r/replace the req option/, fn ->
        request(:get, "/my-index/_search", nil, opts)
      end
    end

    test "handles authentication in endpoint" do
      Application.put_env(:elasticsearch_ex, :clusters, %{
        default: %{
          endpoint: "http://user:pass@localhost:9200",
          req_opts: [plug: {Req.Test, ElasticsearchEx.ClientStub}]
        }
      })

      Req.Test.stub(ElasticsearchEx.ClientStub, fn
        %Plug.Conn{method: "GET", request_path: "/my-index/_search"} = conn ->
          assert conn |> Plug.Conn.get_req_header("authorization") == [
                   "Basic " <> Base.encode64("user:pass")
                 ]

          Req.Test.json(conn, @resp_success)
      end)

      assert {:ok, @resp_success} = request(:get, "/my-index/_search", nil)
    end
  end
end
