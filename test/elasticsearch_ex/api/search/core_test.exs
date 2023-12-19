defmodule ElasticsearchEx.Api.Search.CoreTest do
  use ElasticsearchEx.ConnCase, async: true

  alias ElasticsearchEx.Api.Search.Core, as: Search

  describe "search/2 with POST method" do
    setup do
      http_body = %{
        "_shards" => %{"failed" => 0, "skipped" => 0, "successful" => 0, "total" => 0},
        "hits" => %{
          "hits" => [],
          "max_score" => 0.0,
          "total" => %{"relation" => "eq", "value" => 0}
        },
        "timed_out" => false,
        "took" => 0
      }

      {:ok, http_body: http_body}
    end

    test "returns a sucessful response without an index", %{bypass: bypass, http_body: http_body} do
      expect_once(bypass, "POST", "/_search", http_body, 200)

      assert {:ok, body} = Search.search(%{query: %{match_all: %{}}, size: 1})
      assert body == http_body
    end

    test "returns a sucessful response with an index", %{bypass: bypass, http_body: http_body} do
      expect_once(bypass, "POST", "/hello_world/_search", http_body, 200)

      assert {:ok, body} =
               Search.search(%{query: %{match_all: %{}}, size: 1}, index: :hello_world)

      assert body == http_body
    end
  end

  describe "search/2 returning an error" do
    setup %{bypass: bypass} do
      http_body = %{
        "error" => %{
          "col" => 19,
          "line" => 1,
          "reason" => "[range] query malformed, no start_object after query name",
          "root_cause" => [
            %{
              "col" => 19,
              "line" => 1,
              "reason" => "[range] query malformed, no start_object after query name",
              "type" => "parsing_exception"
            }
          ],
          "type" => "parsing_exception"
        },
        "status" => 400
      }

      expect_once(bypass, "POST", "/_search", http_body, 400)

      {:ok, http_body: http_body}
    end

    test "returns an error if wrong query", %{
      http_body: %{"error" => %{"type" => type, "reason" => reason}}
    } do
      assert {:error, error} = Search.search(%{query: %{match_all: %{}}, size: 1})

      assert %ElasticsearchEx.Error{
               reason: ^reason,
               root_cause: [%{"col" => 19, "line" => 1, "reason" => ^reason, "type" => ^type}],
               status: 400,
               type: ^type
             } = error
    end
  end

  ## Private functions

  defp expect_once(bypass, method, path, body, status) do
    Bypass.expect_once(bypass, method, path, fn conn ->
      conn
      |> Plug.Conn.put_resp_header("Content-Type", "application/json")
      |> Plug.Conn.resp(status, Jason.encode!(body))
    end)
  end
end
