defmodule ElasticsearchEx.Api.Search.TestingTest do
  use ElasticsearchEx.ConnCase

  alias ElasticsearchEx.Api.Search

  ## Module attributes

  @index_name "test_api_search_testing"

  ## Tests

  setup_all do
    on_exit(fn -> delete_index(@index_name) end)
    create_index(@index_name, %{message: %{type: :keyword}})
    fake_id = generate_id()

    {:ok, doc_ids: index_documents(@index_name, 3), fake_id: fake_id}
  end

  describe "search_template/3" do
    test "returns a successful response", %{doc_ids: [doc_id | _]} do
      assert {:ok,
              %{
                "_id" => ^doc_id,
                "_index" => @index_name,
                "explanation" => %{
                  "description" => <<"_id:", _::binary>>,
                  "details" => [],
                  "value" => 1.0
                },
                "matched" => true
              }} = Search.explain(%{query: %{term: %{_id: doc_id}}}, @index_name, doc_id)
    end
  end

  describe "field_capabilities/3" do
    test "returns a successful response with fields as list" do
      assert {:ok,
              %{
                "fields" => %{
                  "message" => %{
                    "keyword" => %{
                      "aggregatable" => true,
                      "metadata_field" => false,
                      "searchable" => true,
                      "type" => "keyword"
                    }
                  }
                },
                "indices" => [@index_name]
              }} = Search.field_capabilities([:message], @index_name)
    end

    test "returns a successful response with fields as binary" do
      assert {:ok,
              %{
                "fields" => %{
                  "message" => %{
                    "keyword" => %{
                      "aggregatable" => true,
                      "metadata_field" => false,
                      "searchable" => true,
                      "type" => "keyword"
                    }
                  }
                },
                "indices" => [@index_name]
              }} = Search.field_capabilities("message", @index_name)
    end

    test "raise an error" do
      assert_raise ArgumentError,
                   "the argument `fields` must be a binary or a list of binaries",
                   fn ->
                     Search.field_capabilities({:message}, @index_name)
                   end
    end
  end

  describe "profile/3" do
    test "returns a successful response", %{fake_id: fake_id} do
      assert {:ok,
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
                "profile" => %{
                  "shards" => [
                    %{
                      "aggregations" => [],
                      "cluster" => "(local)",
                      "id" => _,
                      "index" => @index_name,
                      "node_id" => _,
                      "searches" => [
                        %{
                          "collector" => [
                            %{
                              "children" => [
                                %{
                                  "name" => "SimpleTopScoreDocCollector",
                                  "reason" => "search_top_hits",
                                  "time_in_nanos" => _
                                }
                              ],
                              "name" => "QueryPhaseCollector",
                              "reason" => "search_query_phase",
                              "time_in_nanos" => _
                            }
                          ],
                          "query" => [
                            %{
                              "breakdown" => %{
                                "advance" => 0,
                                "advance_count" => 0,
                                "build_scorer" => _,
                                "build_scorer_count" => 2,
                                "compute_max_score" => 0,
                                "compute_max_score_count" => 0,
                                "count_weight" => 0,
                                "count_weight_count" => 0,
                                "create_weight" => _,
                                "create_weight_count" => 1,
                                "match" => 0,
                                "match_count" => 0,
                                "next_doc" => _,
                                "next_doc_count" => 1,
                                "score" => 0,
                                "score_count" => 0,
                                "set_min_competitive_score" => 0,
                                "set_min_competitive_score_count" => 0,
                                "shallow_advance" => 0,
                                "shallow_advance_count" => 0
                              },
                              "description" => _,
                              "time_in_nanos" => _,
                              "type" => "MultiTermQueryConstantScoreBlendedWrapper"
                            }
                          ],
                          "rewrite_time" => _
                        }
                      ],
                      "shard_id" => 0
                    }
                  ]
                },
                "timed_out" => false,
                "took" => _
              }} = Search.profile(%{query: %{term: %{_id: fake_id}}}, @index_name)
    end
  end

  describe "rank_evaluation/3" do
    test "returns a successful response with index", %{doc_ids: [doc_id | _]} do
      assert {
               :ok,
               %{
                 "details" => %{
                   "my_query" => %{
                     "hits" => [
                       %{
                         "hit" => %{
                           "_id" => ^doc_id,
                           "_index" => @index_name,
                           "_score" => 1.0
                         },
                         "rating" => 0
                       },
                       %{
                         "hit" => %{
                           "_id" => _,
                           "_index" => @index_name,
                           "_score" => 1.0
                         },
                         "rating" => nil
                       },
                       %{
                         "hit" => %{
                           "_id" => _,
                           "_index" => @index_name,
                           "_score" => 1.0
                         },
                         "rating" => nil
                       }
                     ],
                     "metric_details" => %{
                       "mean_reciprocal_rank" => %{
                         "first_relevant" => -1
                       }
                     },
                     "metric_score" => 0.0,
                     "unrated_docs" => [
                       %{
                         "_id" => _,
                         "_index" => @index_name
                       },
                       %{
                         "_id" => _,
                         "_index" => @index_name
                       }
                     ]
                   }
                 },
                 "failures" => %{},
                 "metric_score" => 0.0
               }
             } =
               Search.rank_evaluation(
                 %{
                   requests: [
                     %{
                       id: "my_query",
                       request: %{
                         query: %{
                           match_all: %{}
                         }
                       },
                       ratings: [
                         %{_index: @index_name, _id: doc_id, rating: 0}
                       ]
                     }
                   ],
                   metric: %{
                     mean_reciprocal_rank: %{
                       k: 20,
                       relevant_rating_threshold: 1
                     }
                   }
                 },
                 @index_name
               )
    end
  end

  describe "search_shards/2" do
    test "returns a successful response with index" do
      assert {
               :ok,
               %{
                 "indices" => %{"test_api_search_testing" => %{}},
                 "nodes" => _,
                 "shards" => [
                   [
                     %{
                       "allocation_id" => %{"id" => _},
                       "index" => @index_name,
                       "node" => _,
                       "primary" => true,
                       "relocating_node" => nil,
                       "relocation_failure_info" => %{"failed_attempts" => 0},
                       "shard" => 0,
                       "state" => "STARTED"
                     }
                   ]
                 ]
               }
             } = Search.search_shards(@index_name)
    end
  end

  describe "validate/3" do
    test "returns a successful response with index", %{fake_id: fake_id} do
      assert {:ok,
              %{"_shards" => %{"failed" => 0, "successful" => 1, "total" => 1}, "valid" => true}} =
               Search.validate(%{query: %{term: %{_id: fake_id}}}, @index_name)
    end

    test "returns a successful response without index", %{fake_id: fake_id} do
      assert {:ok,
              %{
                "_shards" => %{"failed" => 0, "successful" => total, "total" => total},
                "valid" => true
              }} = Search.validate(%{query: %{term: %{_id: fake_id}}})
    end
  end
end
