defmodule ElasticsearchEx.UtilsTest do
  use ExUnit.Case, async: true

  alias ElasticsearchEx.Utils

  ## Tests

  describe "format_path/2" do
    test "returns a binary with nil" do
      assert Utils.format_path(nil, :_test) == "/_test"
    end

    test "returns a binary with binary" do
      assert Utils.format_path("my-index", :_test) == "/my-index/_test"
    end

    test "returns a binary with list of binaries" do
      assert Utils.format_path([:"my-index-0", :"my-index-1"], :_test) ==
               "/my-index-0,my-index-1/_test"
    end

    test "returns a binary with atom" do
      assert Utils.format_path(:"my-index", :_test) == "/my-index/_test"
    end
  end

  describe "format_path/3" do
    test "returns a binary with nil" do
      assert Utils.format_path(nil, :_test, "0") == "/_test/0"
    end

    test "returns a binary with binary" do
      assert Utils.format_path("my-index", :_test, "0") == "/my-index/_test/0"
    end

    test "returns a binary with list of binaries" do
      assert Utils.format_path([:"my-index-0", :"my-index-1"], :_test, "0") ==
               "/my-index-0,my-index-1/_test/0"
    end

    test "returns a binary with atom" do
      assert Utils.format_path(:"my-index", :_test, "0") == "/my-index/_test/0"
    end
  end
end
