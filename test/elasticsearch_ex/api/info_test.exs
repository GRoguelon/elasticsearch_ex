defmodule ElasticsearchEx.API.InfoTest do
  use ElasticsearchEx.ConnCase

  alias ElasticsearchEx.API.Info

  ## Tests

  describe "xpack/1" do
    test "returns a successful response" do
      assert {:ok, response} = Info.xpack()
      assert is_map(response)
      assert is_map_key(response, "build")
      assert is_map_key(response, "features")
      assert is_map_key(response, "license")
      assert response["tagline"] == "You know, for X"
    end
  end
end
