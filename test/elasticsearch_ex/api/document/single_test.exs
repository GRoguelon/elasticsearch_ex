defmodule ElasticsearchEx.Api.Document.SingleTest do
  use ElasticsearchEx.ConnCase

  alias ElasticsearchEx.Api.Document

  ## Module attributes

  @index_name "test_api_document_single"

  ## Tests

  setup_all do
    on_exit(fn -> delete_index(@index_name) end)
    create_index(@index_name, %{message: %{type: :keyword}})
    fake_id = generate_id()

    {:ok, doc_ids: index_documents(@index_name, 4), fake_id: fake_id}
  end

  describe "index/2" do
    test "returns a sucessful response" do
      assert {:ok,
              %{
                "_id" => _doc_id,
                "_index" => @index_name,
                "_primary_term" => 1,
                "_seq_no" => _seq_no,
                "_shards" => %{"failed" => 0, "successful" => 1, "total" => 1},
                "_version" => 1,
                "result" => "created"
              }} = Document.index(%{message: "Hello new message"}, @index_name)
    end
  end

  describe "create/2" do
    test "returns a sucessful response" do
      doc_id = generate_id()

      assert {:ok,
              %{
                "_id" => ^doc_id,
                "_index" => @index_name,
                "_primary_term" => 1,
                "_seq_no" => _seq_no,
                "_shards" => %{"failed" => 0, "successful" => 1, "total" => 1},
                "_version" => 1,
                "result" => "created"
              }} = Document.create(%{message: "Hello new message"}, @index_name, doc_id)
    end
  end

  describe "get/1" do
    test "returns a sucessful response", %{doc_ids: [doc_id | _]} do
      assert {:ok,
              %{
                "_id" => ^doc_id,
                "_index" => "test_api_document_single",
                "_primary_term" => 1,
                "_seq_no" => 0,
                "_version" => 1,
                "_source" => %{"message" => "Hello World 1!"},
                "found" => true
              }} = Document.get(@index_name, doc_id)
    end
  end

  describe "exists?/1" do
    test "returns a sucessful response", %{doc_ids: [doc_id | _], fake_id: fake_id} do
      refute Document.exists?(@index_name, fake_id)
      assert Document.exists?(@index_name, doc_id)
    end
  end

  describe "delete/2" do
    test "returns a sucessful response", %{doc_ids: [_ | [_ | [doc_id3 | _]]]} do
      assert {:ok,
              %{
                "_id" => ^doc_id3,
                "_index" => @index_name,
                "_primary_term" => 1,
                "_seq_no" => _seq_no,
                "_version" => 2,
                "_shards" => %{"failed" => 0, "successful" => 1, "total" => 1},
                "result" => "deleted"
              }} = Document.delete(@index_name, doc_id3)
    end

    test "returns a unsucessful response", %{fake_id: doc_id} do
      reason = "Document with ID: `#{doc_id}` not found"

      assert {:error,
              %ElasticsearchEx.Error{
                __exception__: true,
                original: %{
                  "_id" => ^doc_id,
                  "_index" => @index_name,
                  "_primary_term" => 1,
                  "_shards" => %{"failed" => 0, "successful" => 1, "total" => 1},
                  "_version" => 1,
                  "result" => "not_found"
                },
                reason: ^reason,
                root_cause: nil,
                status: 404,
                type: "not_found"
              }} = Document.delete(@index_name, doc_id)
    end
  end

  describe "update/2" do
    @script %{
      source: "ctx._source.message = params.message",
      lang: "painless",
      params: %{message: "Bye World"}
    }

    test "returns a sucessful response", %{doc_ids: [_ | [_ | [_ | [doc_id4]]]]} do
      assert {:ok,
              %{
                "_id" => ^doc_id4,
                "_index" => @index_name,
                "_primary_term" => 1,
                "_seq_no" => _seq_no,
                "_version" => 2,
                "_shards" => %{"failed" => 0, "successful" => 1, "total" => 1},
                "result" => "updated"
              }} = Document.update(%{script: @script}, @index_name, doc_id4)
    end

    test "returns a successful response when document doesn't exist", %{fake_id: doc_id} do
      reason = "[#{doc_id}]: document missing"

      assert {
               :error,
               %ElasticsearchEx.Error{
                 original: %{
                   "index" => @index_name,
                   "index_uuid" => index_uuid,
                   "reason" => ^reason,
                   "root_cause" => [
                     %{
                       "index" => @index_name,
                       "index_uuid" => index_uuid,
                       "reason" => ^reason,
                       "shard" => "0",
                       "type" => "document_missing_exception"
                     }
                   ],
                   "shard" => "0",
                   "type" => "document_missing_exception"
                 },
                 reason: ^reason,
                 root_cause: [
                   %{
                     "index" => @index_name,
                     "index_uuid" => index_uuid,
                     "reason" => ^reason,
                     "shard" => "0",
                     "type" => "document_missing_exception"
                   }
                 ],
                 status: 404,
                 type: "document_missing_exception"
               }
             } = Document.update(%{script: @script}, @index_name, doc_id)
    end
  end
end
