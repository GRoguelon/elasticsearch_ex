defmodule ElasticsearchEx.Api.Document.MultiTest do
  use ElasticsearchEx.ConnCase

  alias ElasticsearchEx.Api.Document

  ## Module attributes

  @index_name "test_api_document_multi"

  ## Tests

  setup_all do
    on_exit(fn -> delete_index(@index_name) end)
    create_index(@index_name, %{message: %{type: :keyword}})
    fake_id = generate_id()

    {:ok, doc_ids: index_documents(@index_name, 4), fake_id: fake_id}
  end

  describe "get_ids/3" do
    test "raises an exception if missing index" do
      assert_raise ArgumentError, "the argument `index` cannot be `nil`", fn ->
        Document.get_ids(["A"], nil)
      end
    end

    test "returns a sucessful response", %{fake_id: fake_id, doc_ids: [doc_id | _]} do
      assert {:ok,
              %{
                "docs" => [
                  %{
                    "_id" => ^doc_id,
                    "_index" => @index_name,
                    "_primary_term" => 1,
                    "_seq_no" => 0,
                    "_source" => %{"message" => "Hello World 1!"},
                    "_version" => 1,
                    "found" => true
                  },
                  %{
                    "_id" => ^fake_id,
                    "_index" => @index_name,
                    "found" => false
                  }
                ]
              }} = Document.get_ids([doc_id, fake_id], @index_name)
    end

    test "returns an error with empty list" do
      assert {
               :error,
               %ElasticsearchEx.Error{
                 original: %{
                   "reason" => "Validation Failed: 1: no documents to get;",
                   "root_cause" => [
                     %{
                       "reason" => "Validation Failed: 1: no documents to get;",
                       "type" => "action_request_validation_exception"
                     }
                   ],
                   "type" => "action_request_validation_exception"
                 },
                 reason: "Validation Failed: 1: no documents to get;",
                 root_cause: [
                   %{
                     "reason" => "Validation Failed: 1: no documents to get;",
                     "type" => "action_request_validation_exception"
                   }
                 ],
                 status: 400,
                 type: "action_request_validation_exception"
               }
             } = Document.get_ids([], @index_name)
    end
  end

  describe "get_docs/3" do
    test "returns a sucessful response with index", %{fake_id: fake_id, doc_ids: [doc_id | _]} do
      assert {:ok,
              %{
                "docs" => [
                  %{
                    "_id" => ^doc_id,
                    "_index" => @index_name,
                    "_primary_term" => 1,
                    "_seq_no" => 0,
                    "_source" => %{"message" => "Hello World 1!"},
                    "_version" => 1,
                    "found" => true
                  },
                  %{
                    "_id" => ^fake_id,
                    "_index" => @index_name,
                    "found" => false
                  }
                ]
              }} = Document.get_docs([%{_id: doc_id}, %{_id: fake_id}], @index_name)
    end

    test "returns a sucessful response without index", %{fake_id: fake_id, doc_ids: [doc_id | _]} do
      assert {:ok,
              %{
                "docs" => [
                  %{
                    "_id" => ^doc_id,
                    "_index" => @index_name,
                    "_primary_term" => 1,
                    "_seq_no" => 0,
                    "_source" => %{"message" => "Hello World 1!"},
                    "_version" => 1,
                    "found" => true
                  },
                  %{
                    "_id" => ^fake_id,
                    "_index" => @index_name,
                    "found" => false
                  }
                ]
              }} =
               Document.get_docs([
                 %{_index: @index_name, _id: doc_id},
                 %{_index: @index_name, _id: fake_id}
               ])
    end

    test "raises an exception without index", %{fake_id: fake_id, doc_ids: [doc_id | _]} do
      assert_raise ArgumentError,
                   ~s<missing key `:_index` in the map, got: `%{_id: "#{fake_id}"}`>,
                   fn ->
                     Document.get_docs([
                       %{_index: @index_name, _id: doc_id},
                       %{_id: fake_id}
                     ])
                   end
    end

    test "returns an error with empty list" do
      assert {
               :error,
               %ElasticsearchEx.Error{
                 original: %{
                   "reason" => "Validation Failed: 1: no documents to get;",
                   "root_cause" => [
                     %{
                       "reason" => "Validation Failed: 1: no documents to get;",
                       "type" => "action_request_validation_exception"
                     }
                   ],
                   "type" => "action_request_validation_exception"
                 },
                 reason: "Validation Failed: 1: no documents to get;",
                 root_cause: [
                   %{
                     "reason" => "Validation Failed: 1: no documents to get;",
                     "type" => "action_request_validation_exception"
                   }
                 ],
                 status: 400,
                 type: "action_request_validation_exception"
               }
             } = Document.get_docs([], @index_name)
    end
  end

  describe "multi_get/1" do
    test "raises an exception if not map or binary" do
      assert_raise ArgumentError,
                   "invalid value, expected a list of maps or document IDs, got: `[{\"A\", \"B\"}]`",
                   fn ->
                     Document.multi_get([{"A", "B"}], @index_name)
                   end
    end

    test "returns a sucessful response with map", %{fake_id: fake_id, doc_ids: [doc_id | _]} do
      assert {:ok,
              %{
                "docs" => [
                  %{
                    "_id" => ^doc_id,
                    "_index" => @index_name,
                    "_primary_term" => 1,
                    "_seq_no" => 0,
                    "_source" => %{"message" => "Hello World 1!"},
                    "_version" => 1,
                    "found" => true
                  },
                  %{
                    "_id" => ^fake_id,
                    "_index" => @index_name,
                    "found" => false
                  }
                ]
              }} = Document.multi_get([%{_id: doc_id}, %{_id: fake_id}], @index_name)
    end

    test "returns a sucessful response with binary", %{fake_id: fake_id, doc_ids: [doc_id | _]} do
      assert {:ok,
              %{
                "docs" => [
                  %{
                    "_id" => ^doc_id,
                    "_index" => @index_name,
                    "_primary_term" => 1,
                    "_seq_no" => 0,
                    "_source" => %{"message" => "Hello World 1!"},
                    "_version" => 1,
                    "found" => true
                  },
                  %{
                    "_id" => ^fake_id,
                    "_index" => @index_name,
                    "found" => false
                  }
                ]
              }} = Document.multi_get([doc_id, fake_id], @index_name)
    end
  end
end
