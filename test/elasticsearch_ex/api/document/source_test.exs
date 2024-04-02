defmodule ElasticsearchEx.Api.Document.SourceTest do
  use ElasticsearchEx.ConnCase

  alias ElasticsearchEx.Api.Document.Source

  ## Module attributes

  @index_name "test_api_source"

  ## Tests

  setup_all do
    on_exit(fn -> delete_index(@index_name) end)
    create_index(@index_name, %{message: %{type: :keyword}})
    fake_id = generate_id()

    {:ok, doc_ids: index_documents(@index_name, 4), fake_id: fake_id}
  end

  describe "get/1" do
    test "raises an exception if missing index", %{fake_id: doc_id} do
      assert_raise KeyError, ~s<key :index not found in: [id: "#{doc_id}"]>, fn ->
        Source.get(id: doc_id)
      end
    end

    test "raises an exception if missing ID" do
      assert_raise KeyError, "key :id not found in: []", fn ->
        Source.get(index: @index_name)
      end
    end

    test "returns a sucessful response", %{doc_ids: [doc_id | _]} do
      assert {:ok, %{"message" => "Hello World 1!"}} = Source.get(index: @index_name, id: doc_id)
    end
  end

  describe "exists?/1" do
    test "raises an exception if missing index", %{fake_id: doc_id} do
      assert_raise KeyError, ~s<key :index not found in: [id: "#{doc_id}"]>, fn ->
        Source.exists?(id: doc_id)
      end
    end

    test "raises an exception if missing ID" do
      assert_raise KeyError, "key :id not found in: []", fn ->
        Source.exists?(index: @index_name)
      end
    end

    test "returns a sucessful response", %{doc_ids: [doc_id | _], fake_id: fake_id} do
      refute Source.exists?(index: @index_name, id: fake_id)
      assert Source.exists?(index: @index_name, id: doc_id)
    end
  end
end
