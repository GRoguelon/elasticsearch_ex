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

  describe "search/2" do
    test "returns a sucessful response", %{doc_ids: [doc_id | _]} do
      assert {:ok,
              %{
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
                "took" => _took
              }} = Search.search(%{query: %{term: %{_id: doc_id}}, size: 1}, index: @index_name)
    end
  end

  describe "multi_search/2" do
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
                 index: @index_name
               )
    end
  end

  describe "async_search/2" do
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
    test "raises an exception if missing index" do
      assert_raise KeyError, fn -> Search.create_pit() end
    end

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
    test "raises an exception if missing index" do
      assert_raise KeyError, fn ->
        Search.terms_enum(%{field: :message, string: "hello", case_insensitive: true})
      end
    end

    test "returns a sucessful response" do
      assert {:ok,
              %{
                "_shards" => %{"failed" => 0, "successful" => 1, "total" => 1},
                "complete" => true,
                "terms" => ["Hello World 1!", "Hello World 2!", "Hello World 3!"]
              }} =
               Search.terms_enum(%{field: :message, string: "hello", case_insensitive: true},
                 index: @index_name
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
               Search.search(%{query: %{match_all: %{}}, size: 1},
                 scroll: "5s",
                 index: @index_name
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
               Search.search(%{query: %{match_all: %{}}, size: 1},
                 scroll: "5s",
                 index: @index_name
               )

      assert {:ok, %{"num_freed" => 1, "succeeded" => true}} = Search.clear_scroll(scroll_id)
    end
  end

  ## Private functions

  defp async_search(doc_id) do
    {:ok, _} =
      Search.async_search(%{query: %{term: %{_id: doc_id}}, size: 1},
        index: @index_name,
        keep_on_completion: true,
        keep_alive: "5s"
      )
  end

  defp create_pit do
    {:ok, _} = Search.create_pit(index: @index_name, keep_alive: "5s")
  end
end
