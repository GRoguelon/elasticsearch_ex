defmodule ElasticsearchEx.Api.Search.CoreTest do
  use ElasticsearchEx.ConnCase

  alias ElasticsearchEx.Api.Search

  ## Module attributes

  @index_name "test_api_search_core"

  ## Tests

  setup_all do
    on_exit(fn -> delete_index(@index_name) end)
    create_index(@index_name, %{message: %{type: :keyword}})

    {:ok, doc_ids: index_documents(@index_name, 3)}
  end

  describe "search/0" do
    test "returns a sucessful response" do
      assert {:ok, %{"hits" => %{"hits" => hits}}} = Search.search()
      assert length(hits) >= 3
    end
  end

  describe "search/1" do
    test "returns a sucessful response with query", %{doc_ids: [doc_id | _]} do
      assert {:ok, %{"hits" => %{"hits" => hits}}} =
               Search.search(%{query: %{term: %{_id: doc_id}}, size: 1})

      assert length(hits) == 1
    end

    test "returns a sucessful response with index" do
      assert {:ok, %{"hits" => %{"hits" => hits}}} = Search.search(@index_name)
      assert length(hits) == 3
    end

    test "returns a sucessful response with index as nil" do
      assert {:ok, %{"hits" => %{"hits" => hits}}} = Search.search(nil)
      assert length(hits) >= 3
    end

    test "returns a sucessful response with opts true" do
      assert {:ok, %{"hits" => %{"hits" => [hit1 | _] = hits}}} = Search.search(_source: true)
      assert length(hits) >= 3
      assert is_map_key(hit1, "_source")
    end

    test "returns a sucessful response with opts false" do
      assert {:ok, %{"hits" => %{"hits" => [hit1 | _] = hits}}} = Search.search(_source: false)
      assert length(hits) >= 3
      refute is_map_key(hit1, "_source")
    end
  end

  describe "search/2" do
    test "returns a sucessful response with query and index as nil", %{doc_ids: [doc_id | _]} do
      assert {:ok, %{"hits" => %{"hits" => hits}}} =
               Search.search(%{query: %{term: %{_id: doc_id}}, size: 1}, nil)

      assert length(hits) == 1
    end

    test "returns a sucessful response with query and index", %{doc_ids: [doc_id | _]} do
      assert {:ok, %{"hits" => %{"hits" => hits}}} =
               Search.search(%{query: %{term: %{_id: doc_id}}, size: 1}, @index_name)

      assert length(hits) == 1
    end

    test "returns a sucessful response with query and fake index", %{doc_ids: [doc_id | _]} do
      assert {:error,
              %ElasticsearchEx.Error{
                reason: "no such index [fake_index]",
                status: 404,
                type: "index_not_found_exception"
              }} = Search.search(%{query: %{term: %{_id: doc_id}}, size: 1}, :fake_index)
    end

    test "returns a sucessful response with index and opts" do
      assert {:ok, %{"hits" => %{"hits" => hits}}} = Search.search(@index_name, _source: false)

      assert length(hits) == 3
    end

    test "returns a sucessful response with index as nil and opts as true" do
      assert {:ok, %{"hits" => %{"hits" => [hit1 | _] = hits}}} =
               Search.search(nil, _source: true)

      assert length(hits) >= 3
      assert is_map_key(hit1, "_source")
    end

    test "returns a sucessful response with index as nil and opts as false" do
      assert {:ok, %{"hits" => %{"hits" => hits}}} = Search.search(nil, _source: false)

      assert length(hits) >= 3
    end

    test "returns a sucessful response with query and opts", %{doc_ids: [doc_id | _]} do
      assert {:ok, %{"hits" => %{"hits" => [hit1]}}} =
               Search.search(%{query: %{term: %{_id: doc_id}}, size: 1}, _source: false)

      refute is_map_key(hit1, "_source")
    end
  end

  describe "search/3" do
    test "returns a sucessful response", %{doc_ids: [doc_id | _]} do
      assert {:ok, %{"hits" => %{"hits" => [hit1]}}} =
               Search.search(%{query: %{term: %{_id: doc_id}}, size: 1}, @index_name,
                 _source: false
               )

      refute is_map_key(hit1, "_source")
    end

    test "returns an error", %{doc_ids: [doc_id | _]} do
      assert {:error,
              %ElasticsearchEx.Error{
                reason: "no such index [fake_index]",
                status: 404,
                type: "index_not_found_exception"
              }} =
               Search.search(%{query: %{term: %{_id: doc_id}}, size: 1}, :fake_index,
                 _source: false
               )
    end
  end

  describe "multi_search/3" do
    test "returns a sucessful response", %{doc_ids: [doc_id1 | [doc_id2 | _]]} do
      assert {
               :ok,
               %{
                 "took" => _,
                 "responses" => [
                   %{
                     "_shards" => %{
                       "failed" => 0,
                       "skipped" => 0,
                       "successful" => 1,
                       "total" => 1
                     },
                     "hits" => %{
                       "hits" => [
                         %{
                           "_id" => ^doc_id1,
                           "_index" => @index_name,
                           "_score" => 1.0,
                           "_source" => %{"message" => "Hello World 1!"}
                         }
                       ],
                       "max_score" => 1.0,
                       "total" => %{"relation" => "eq", "value" => 1}
                     },
                     "status" => 200,
                     "timed_out" => false,
                     "took" => _
                   },
                   %{
                     "_shards" => %{
                       "failed" => 0,
                       "skipped" => 0,
                       "successful" => 1,
                       "total" => 1
                     },
                     "hits" => %{
                       "hits" => [
                         %{
                           "_id" => ^doc_id2,
                           "_index" => @index_name,
                           "_score" => 1.0
                         }
                       ],
                       "max_score" => 1.0,
                       "total" => %{"relation" => "eq", "value" => 1}
                     },
                     "status" => 200,
                     "timed_out" => false,
                     "took" => _
                   }
                 ]
               }
             } =
               Search.multi_search(
                 [
                   %{},
                   %{query: %{term: %{_id: doc_id1}}, size: 1},
                   %{index: @index_name},
                   %{query: %{term: %{_id: doc_id2}}, _source: false, size: 1}
                 ],
                 @index_name
               )
    end
  end

  describe "async_search/3" do
    test "returns a sucessful response", %{doc_ids: [doc_id | _]} do
      assert {:ok,
              %{
                "completion_time_in_millis" => _,
                "expiration_time_in_millis" => _,
                "id" => async_id,
                "is_partial" => false,
                "is_running" => false,
                "response" => %{
                  "_shards" => %{"failed" => 0, "skipped" => 0, "successful" => 1, "total" => 1},
                  "hits" => %{
                    "hits" => [
                      %{
                        "_id" => ^doc_id,
                        "_index" => @index_name,
                        "_score" => 1.0,
                        "_source" => %{"message" => "Hello World 1!"}
                      }
                    ],
                    "max_score" => 1.0,
                    "total" => %{"relation" => "eq", "value" => 1}
                  },
                  "timed_out" => false,
                  "took" => _
                },
                "start_time_in_millis" => _
              }} = async_search(doc_id)

      assert is_binary(async_id)
    end
  end

  describe "get_async_search/2" do
    test "returns a sucessful response", %{doc_ids: [doc_id | _]} do
      {:ok, %{"id" => async_id}} = async_search(doc_id)

      assert {:ok,
              %{
                "completion_time_in_millis" => _,
                "expiration_time_in_millis" => _,
                "id" => ^async_id,
                "is_partial" => false,
                "is_running" => false,
                "response" => %{
                  "_shards" => %{"failed" => 0, "skipped" => 0, "successful" => 1, "total" => 1},
                  "hits" => %{
                    "hits" => [
                      %{
                        "_id" => ^doc_id,
                        "_index" => @index_name,
                        "_score" => 1.0,
                        "_source" => %{"message" => "Hello World 1!"}
                      }
                    ],
                    "max_score" => 1.0,
                    "total" => %{"relation" => "eq", "value" => 1}
                  },
                  "timed_out" => false,
                  "took" => _
                },
                "start_time_in_millis" => _
              }} = Search.get_async_search(async_id)
    end
  end

  describe "delete_async_search/2" do
    test "returns a sucessful response", %{doc_ids: [doc_id | _]} do
      {:ok, %{"id" => async_id}} = async_search(doc_id)

      assert {:ok, %{"acknowledged" => true}} = Search.delete_async_search(async_id)
    end
  end

  describe "create_pit/1" do
    test "returns a sucessful response" do
      assert {:ok, %{"id" => pit_id}} = create_pit()
      assert is_binary(pit_id)
    end
  end

  describe "close_pit/2" do
    test "returns a sucessful response" do
      {:ok, %{"id" => pit_id}} = create_pit()

      assert {:ok, %{"num_freed" => 1, "succeeded" => true}} = Search.close_pit(pit_id)
    end
  end

  describe "terms_enum/2" do
    test "returns a sucessful response" do
      assert {:ok,
              %{
                "_shards" => %{"failed" => 0, "successful" => 1, "total" => 1},
                "complete" => true,
                "terms" => ["Hello World 1!", "Hello World 2!", "Hello World 3!"]
              }} =
               Search.terms_enum(
                 %{field: :message, string: "hello", case_insensitive: true},
                 @index_name
               )
    end
  end

  describe "get_scroll/2" do
    test "returns a sucessful response", %{doc_ids: [doc_id1 | [doc_id2 | _]]} do
      assert {
               :ok,
               %{
                 "_scroll_id" => scroll_id,
                 "_shards" => %{"failed" => 0, "successful" => 1, "total" => 1, "skipped" => 0},
                 "hits" => %{
                   "hits" => [
                     %{
                       "_id" => ^doc_id1,
                       "_index" => @index_name,
                       "_score" => 1.0,
                       "_source" => %{"message" => "Hello World 1!"}
                     }
                   ],
                   "max_score" => 1.0,
                   "total" => %{"relation" => "eq", "value" => 3}
                 },
                 "timed_out" => false,
                 "took" => _
               }
             } =
               Search.search(
                 %{query: %{match_all: %{}}, size: 1},
                 @index_name,
                 scroll: "5s"
               )

      assert {
               :ok,
               %{
                 "_shards" => %{"failed" => 0, "successful" => 1, "total" => 1, "skipped" => 0},
                 "hits" => %{
                   "hits" => [
                     %{
                       "_id" => ^doc_id2,
                       "_index" => @index_name,
                       "_score" => 1.0,
                       "_source" => %{"message" => "Hello World 2!"}
                     }
                   ],
                   "max_score" => 1.0,
                   "total" => %{"relation" => "eq", "value" => 3}
                 },
                 "timed_out" => false,
                 "took" => _
               }
             } = Search.get_scroll(scroll_id)
    end
  end

  describe "clear_scroll/2" do
    test "returns a sucessful response" do
      assert {:ok, %{"_scroll_id" => scroll_id}} =
               Search.search(
                 %{query: %{match_all: %{}}, size: 1},
                 @index_name,
                 scroll: "5s"
               )

      assert {:ok, %{"num_freed" => 1, "succeeded" => true}} = Search.clear_scroll(scroll_id)
    end
  end

  ## Private functions

  defp async_search(doc_id) do
    {:ok, _} =
      Search.async_search(
        %{query: %{term: %{_id: doc_id}}, size: 1},
        @index_name,
        keep_on_completion: true,
        keep_alive: "5s"
      )
  end

  defp create_pit do
    {:ok, _} = Search.create_pit(@index_name, keep_alive: "5s")
  end
end
