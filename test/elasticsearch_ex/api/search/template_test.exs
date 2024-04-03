defmodule ElasticsearchEx.Api.Search.TemplateTest do
  use ElasticsearchEx.ConnCase

  alias ElasticsearchEx.Api.Search

  ## Module attributes

  @index_name "test_api_search_template"

  ## Tests

  setup_all do
    on_exit(fn -> delete_index(@index_name) end)
    create_index(@index_name, %{message: %{type: :keyword}})
    create_template()
    fake_id = generate_id()

    {:ok, doc_ids: index_documents(@index_name, 3), fake_id: fake_id}
  end

  describe "search_template/3" do
    test "raises an error if no ID in the body", %{doc_ids: [doc_id | _]} do
      assert_raise ArgumentError,
                   ~s<missing key `:id` in the map, got: `%{params: %{value: "#{doc_id}"}}`>,
                   fn ->
                     Search.search_template(%{params: %{value: doc_id}}, @index_name)
                   end
    end

    test "returns a sucessful response with index", %{doc_ids: [doc_id | _]} do
      assert {:ok,
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
                      "_id" => ^doc_id,
                      "_index" => @index_name,
                      "_score" => 1.0
                    }
                  ],
                  "max_score" => 1.0,
                  "total" => %{"relation" => "eq", "value" => 1}
                },
                "timed_out" => false,
                "took" => _
              }} =
               Search.search_template(
                 %{id: "my-search-template", params: %{value: doc_id}},
                 @index_name
               )
    end

    test "returns a sucessful response without index", %{fake_id: fake_id} do
      assert {
               :ok,
               %{
                 "_shards" => %{
                   "failed" => 0,
                   "skipped" => 0,
                   "successful" => total,
                   "total" => total
                 },
                 "hits" => %{
                   "hits" => [],
                   "max_score" => nil,
                   "total" => %{"relation" => "eq", "value" => 0}
                 },
                 "timed_out" => false,
                 "took" => _
               }
             } = Search.search_template(%{id: "my-search-template", params: %{value: fake_id}})
    end
  end

  describe "multi_search_template/3" do
    test "returns a sucessful response with index", %{doc_ids: [doc_id | _], fake_id: fake_id} do
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
                           "_id" => ^doc_id,
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
                   },
                   %{
                     "_shards" => %{
                       "failed" => 0,
                       "skipped" => 0,
                       "successful" => 1,
                       "total" => 1
                     },
                     "hits" => %{
                       "hits" => [],
                       "max_score" => nil,
                       "total" => %{"relation" => "eq", "value" => 0}
                     },
                     "status" => 200,
                     "timed_out" => false,
                     "took" => _
                   }
                 ]
               }
             } =
               Search.multi_search_template(
                 [
                   %{id: "my-search-template", params: %{value: doc_id}},
                   %{id: "my-search-template", params: %{value: fake_id}}
                 ],
                 @index_name
               )
    end

    test "returns a sucessful response without index", %{doc_ids: [doc_id | _], fake_id: fake_id} do
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
                           "_id" => ^doc_id,
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
                   },
                   %{
                     "_shards" => %{
                       "failed" => 0,
                       "skipped" => 0,
                       "successful" => 1,
                       "total" => 1
                     },
                     "hits" => %{
                       "hits" => [],
                       "max_score" => nil,
                       "total" => %{"relation" => "eq", "value" => 0}
                     },
                     "status" => 200,
                     "timed_out" => false,
                     "took" => _
                   }
                 ]
               }
             } =
               Search.multi_search_template([
                 {%{index: @index_name}, %{id: "my-search-template", params: %{value: doc_id}}},
                 {%{index: @index_name}, %{id: "my-search-template", params: %{value: fake_id}}}
               ])
    end
  end

  describe "render_search_template/3" do
    test "returns a sucessful response with index", %{doc_ids: [doc_id | _]} do
      assert {:ok,
              %{
                "template_output" => %{
                  "_source" => false,
                  "query" => %{"term" => %{"_id" => ^doc_id}},
                  "size" => 1
                }
              }} =
               Search.render_search_template(%{params: %{value: doc_id}}, "my-search-template")
    end

    test "returns a sucessful response without index", %{fake_id: fake_id} do
      assert {:ok,
              %{
                "template_output" => %{
                  "_source" => false,
                  "query" => %{"term" => %{"_id" => ^fake_id}},
                  "size" => 1
                }
              }} =
               Search.render_search_template(%{
                 id: "my-search-template",
                 params: %{value: fake_id}
               })
    end
  end

  ## Private functions

  defp create_template do
    {:ok, %{"acknowledged" => true}} =
      ElasticsearchEx.Client.put("_scripts/my-search-template", nil, %{
        script: %{
          lang: "mustache",
          source: %{
            query: %{
              term: %{
                _id: "{{value}}"
              }
            },
            size: 1,
            _source: false
          },
          params: %{
            value: "Term value"
          }
        }
      })
  end
end
