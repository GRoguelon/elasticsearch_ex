defmodule ElasticsearchEx.Api.Search.CoreTest do
  use ExUnit.Case, async: true

  alias ElasticsearchEx.Api.Search.Core, as: Search

  @search_resp_body %{
    "_shards" => %{"failed" => 0, "skipped" => 0, "successful" => 0, "total" => 0},
    "hits" => %{"hits" => [], "max_score" => 0.0},
    "timed_out" => false,
    "took" => 2
  }

  setup do
    bypass = Bypass.open()

    {:ok, bypass: bypass}
  end

  describe "search/2 with POST method" do
    test "returns1 a sucessful response", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/_search", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("Content-Type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(@search_resp_body))
      end)

      assert {:ok, response} =
               Search.search(%{query: %{match_all: %{}}, size: 1},
                 url: "http://localhost:#{bypass.port}/_search"
               )

      assert response.body == @search_resp_body
    end
  end

  describe "search/2 with GET method" do
    test "returns1 a sucessful response", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/_search", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("Content-Type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(@search_resp_body))
      end)

      assert {:ok, response} =
               Search.search(%{query: %{match_all: %{}}, size: 1},
                 url: "http://localhost:#{bypass.port}/_search",
                 http_method: :get
               )

      assert response.body == @search_resp_body
    end
  end
end
