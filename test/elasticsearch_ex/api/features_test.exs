defmodule ElasticsearchEx.Api.FeaturesTest do
  use ElasticsearchEx.ConnCase

  alias ElasticsearchEx.Api.Features

  ## Tests

  describe "get/1" do
    test "returns a successful response" do
      assert {:ok, response} = Features.get()
      assert is_map(response)
      assert is_map_key(response, "features")

      Enum.map(response["features"], fn feature ->
        assert is_map_key(feature, "description")
        assert is_map_key(feature, "name")
      end)
    end
  end

  describe "reset/1" do
    test "returns a successful response" do
      assert {:ok, response} = Features.reset()
      assert is_map(response)
      assert is_map_key(response, "features")

      Enum.map(response["features"], fn feature ->
        assert is_map_key(feature, "feature_name")
        assert is_map_key(feature, "status")
      end)
    end
  end
end
