defmodule ElasticsearchEx.Api.Search.CoreTest do
  use ElasticsearchEx.ConnCase, async: true

  alias ElasticsearchEx.Api.Search.Core, as: Search

  @search_resp_body %{
    "_shards" => %{"failed" => 0, "skipped" => 0, "successful" => 0, "total" => 0},
    "hits" => %{"hits" => [], "max_score" => 0.0, "total" => %{"relation" => "eq", "value" => 0}},
    "timed_out" => false,
    "took" => 0
  }

  describe "search/2 with POST method" do
    setup %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/_all/_search", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("Content-Type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(@search_resp_body))
      end)
    end

    test "returns a sucessful response" do
      assert {:ok, body} = Search.search(%{query: %{match_all: %{}}, size: 1})
      assert body == @search_resp_body
    end
  end
end
