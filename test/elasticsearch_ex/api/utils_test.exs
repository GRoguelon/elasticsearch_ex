defmodule ElasticsearchEx.Api.UtilsTest do
  use ExUnit.Case, async: true

  alias ElasticsearchEx.Api.Utils

  describe "merge_paths/1" do
    test "returns a tuple with the index as a atom and the other options" do
      assert "/my-index/_doc" == Utils.merge_path_items([:"my-index", "_doc", nil])
      assert "/my-index/_doc/my-id" == Utils.merge_path_items([:"my-index", "_doc", "my-id"])
    end
  end

  describe "extract_required_index_and_optional_id!/1" do
    test "raises an exception if index is missing" do
      assert_raise KeyError, "key :index not found in: []", fn ->
        Utils.extract_required_index_and_optional_id!([])
      end
    end

    test "returns the index, id and opts from the arguments when id is present" do
      assert {:my_index, "my_id", a: :b} =
               Utils.extract_required_index_and_optional_id!(index: :my_index, id: "my_id", a: :b)
    end

    test "returns the index, id and opts from the arguments when id is missing" do
      assert {:my_index, nil, a: :b} =
               Utils.extract_required_index_and_optional_id!(index: :my_index, a: :b)
    end
  end

  describe "extract_required_index_and_required_id!/1" do
    test "raises an exception if index is missing" do
      assert_raise KeyError, "key :index not found in: []", fn ->
        Utils.extract_required_index_and_required_id!([])
      end
    end

    test "raises an exception if id is missing" do
      assert_raise KeyError, "key :id not found in: []", fn ->
        Utils.extract_required_index_and_required_id!(index: :my_index)
      end
    end

    test "returns the index, id and opts from the arguments" do
      assert {:my_index, "my_id", a: :b} =
               Utils.extract_required_index_and_required_id!(index: :my_index, id: "my_id", a: :b)
    end
  end

  describe "extract_optional_index/1" do
    test "returns a tuple with the index as a atom and the other options" do
      assert {:hello, [http_opts: [ssl: false]]} =
               Utils.extract_optional_index(index: :hello, http_opts: [ssl: false])
    end

    test "returns a tuple with the index as a string and the other options" do
      assert {"hello", [http_opts: [ssl: false]]} =
               Utils.extract_optional_index(index: "hello", http_opts: [ssl: false])
    end

    test "returns a tuple with the index as nil and the other options" do
      assert {nil, [http_opts: [ssl: false]]} =
               Utils.extract_optional_index(http_opts: [ssl: false])
    end
  end

  describe "extract_optional_index/2" do
    test "returns a tuple with the index as a atom and the other options" do
      assert {:hello, [http_opts: [ssl: false]]} =
               Utils.extract_optional_index([index: :hello, http_opts: [ssl: false]], :bye)
    end

    test "returns a tuple with the default index and the other options" do
      assert {:bye, [http_opts: [ssl: false]]} =
               Utils.extract_optional_index([http_opts: [ssl: false]], :bye)
    end
  end

  describe "extract_required_index!/1" do
    test "returns a tuple with the index as a atom and the other options" do
      assert {:hello, [http_opts: [ssl: false]]} =
               Utils.extract_required_index!(index: :hello, http_opts: [ssl: false])
    end

    test "returns a tuple with the index as a string and the other options" do
      assert {"hello", [http_opts: [ssl: false]]} =
               Utils.extract_required_index!(index: "hello", http_opts: [ssl: false])
    end

    test "raises an exception with missing index" do
      assert_raise KeyError, "key :index not found in: [http_opts: [ssl: false]]", fn ->
        Utils.extract_required_index!(http_opts: [ssl: false])
      end
    end
  end
end
