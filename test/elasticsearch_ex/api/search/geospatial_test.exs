defmodule ElasticsearchEx.Api.Search.GeospatialTest do
  use ElasticsearchEx.ConnCase

  alias ElasticsearchEx.Api.Search

  ## Module attributes

  @index_name "test_api_search_geospacial"

  ## Tests

  setup_all do
    on_exit(fn -> delete_index(@index_name) end)
    create_index(@index_name, %{location: %{type: :geo_point}})

    {:ok, %{"_id" => doc_id}} =
      ElasticsearchEx.Api.Document.index(
        %{location: %{type: "Point", coordinates: [-71.34, 41.12]}},
        @index_name
      )

    {:ok, doc_id: doc_id}
  end

  describe "search_vector_tile/6" do
    test "returns successful response" do
      assert {:ok, vector_tile} = Search.search_vector_tile(@index_name, :location, 29, 552, 12)
      assert is_binary(vector_tile)
      assert byte_size(vector_tile) > 0
    end
  end
end
