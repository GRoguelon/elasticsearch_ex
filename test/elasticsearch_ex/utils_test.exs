defmodule ElasticsearchEx.UtilsTest do
  use ExUnit.Case, async: true

  alias ElasticsearchEx.Utils

  ## Tests

  describe "generate_path/1" do
    test "returns a binary with non-nil values" do
      assert Utils.generate_path([:_search, "my-index-1"]) == "/_search/my-index-1"
    end

    test "returns a binary with nil values" do
      assert Utils.generate_path([:_search, nil]) == "/_search"
    end
  end
end
