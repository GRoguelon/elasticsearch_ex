defmodule ElasticsearchEx.Api.UsageTest do
  use ElasticsearchEx.ConnCase

  alias ElasticsearchEx.Api.Usage

  ## Tests

  describe "xpack/1" do
    test "returns a successful response" do
      assert {:ok, response} = Usage.xpack()
      assert is_map(response)
      assert map_size(response) > 0
    end
  end
end
