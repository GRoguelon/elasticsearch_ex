defmodule ElasticsearchEx.Api.Document.SourceTest do
  use ElasticsearchEx.ConnCase

  alias ElasticsearchEx.Api.Document.Source

  ## Module attributes

  @index_name "test_api_document_source"

  ## Tests

  setup_all do
    on_exit(fn -> delete_index(@index_name) end)
    create_index(@index_name, %{message: %{type: :keyword}})
    fake_id = generate_id()

    {:ok, doc_ids: index_documents(@index_name, 4), fake_id: fake_id}
  end

  describe "get/1" do
    test "returns a sucessful response", %{doc_ids: [doc_id | _]} do
      assert {:ok, %{"message" => "Hello World 1!"}} =
               Source.get(@index_name, doc_id, _source_includes: "message")
    end

    test "returns a sucessful response 2", %{doc_ids: [doc_id | _]} do
      assert {:ok, %{}} = Source.get(@index_name, doc_id, _source_includes: "message2")
    end
  end

  describe "exists?/1" do
    test "returns a sucessful response", %{doc_ids: [doc_id | _], fake_id: fake_id} do
      refute Source.exists?(@index_name, fake_id)
      assert Source.exists?(@index_name, doc_id)
    end
  end
end
