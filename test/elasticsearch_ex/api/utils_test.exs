defmodule ElasticsearchEx.Api.UtilsTest do
  use ExUnit.Case, async: true

  alias ElasticsearchEx.Api.Utils

  describe "extract_index/1" do
    test "returns a tuple with the index as a atom and the other options" do
      assert {:hello, [http_opts: [ssl: false]]} =
               Utils.extract_index(index: :hello, http_opts: [ssl: false])
    end

    test "returns a tuple with the index as a string and the other options" do
      assert {"hello", [http_opts: [ssl: false]]} =
               Utils.extract_index(index: "hello", http_opts: [ssl: false])
    end

    test "returns a tuple with the index as nil and the other options" do
      assert {nil, [http_opts: [ssl: false]]} = Utils.extract_index(http_opts: [ssl: false])
    end
  end

  describe "extract_index/2" do
    test "returns a tuple with the index as a atom and the other options" do
      assert {:hello, [http_opts: [ssl: false]]} =
               Utils.extract_index([index: :hello, http_opts: [ssl: false]], :bye)
    end

    test "returns a tuple with the default index and the other options" do
      assert {:bye, [http_opts: [ssl: false]]} =
               Utils.extract_index([http_opts: [ssl: false]], :bye)
    end
  end

  describe "extract_index!/1" do
    test "returns a tuple with the index as a atom and the other options" do
      assert {:hello, [http_opts: [ssl: false]]} =
               Utils.extract_index!(index: :hello, http_opts: [ssl: false])
    end

    test "returns a tuple with the index as a string and the other options" do
      assert {"hello", [http_opts: [ssl: false]]} =
               Utils.extract_index!(index: "hello", http_opts: [ssl: false])
    end

    test "raises an exception with missing index" do
      assert_raise KeyError, "key :index not found in: [http_opts: [ssl: false]]", fn ->
        Utils.extract_index!(http_opts: [ssl: false])
      end
    end
  end

  describe "merge_path_suffix/2" do
    test "returns only the suffix when the path is nil" do
      assert "/_search" = Utils.merge_path_suffix(nil, "_search")
    end

    test "returns the merged path and suffix as a string" do
      assert "/my_index_001/_search" = Utils.merge_path_suffix("my_index_001", "_search")
    end
  end
end
