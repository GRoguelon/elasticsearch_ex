defmodule ElasticsearchEx.MappingsCacherTest do
  use ExUnit.Case, async: false

  alias ElasticsearchEx.MappingsCacher
  alias ElasticsearchEx.Client

  ## Module attributes

  @index_name "test_index"
  @index_name_2 "test_index_2"
  @mapping %{"mappings" => %{"properties" => %{"field" => %{"type" => "keyword"}}}}
  @mapping_2 %{"mappings" => %{"properties" => %{"field2" => %{"type" => "text"}}}}

  setup do
    # Clean up test indices before each test
    Client.request(:delete, "/#{@index_name}")
    Client.request(:delete, "/#{@index_name_2}")

    # Create test index with mapping
    Client.request(:put, "/#{@index_name}", @mapping)

    # Clear cache to ensure fresh state
    MappingsCacher.clear()

    on_exit(fn ->
      # Clean up after test
      Client.request(:delete, "/#{@index_name}")
      Client.request(:delete, "/#{@index_name_2}")
    end)

    :ok
  end

  describe "get/2" do
    import MappingsCacher, only: [get: 1]

    test "returns cached mapping if exists" do
      # First call populates cache
      assert %{"properties" => %{"field" => %{"type" => "keyword"}}} = get(@index_name)

      # Second call should hit cache
      assert %{"properties" => %{"field" => %{"type" => "keyword"}}} = get(@index_name)

      # Verify state
      state = :sys.get_state(MappingsCacher)
      assert Map.has_key?(state.mappings, @index_name)
    end

    test "fetches mapping if not in cache" do
      # Create another index
      Client.request(:put, "/#{@index_name_2}", @mapping_2)

      assert %{"properties" => %{"field2" => %{"type" => "text"}}} = get(@index_name_2)

      # Verify state
      state = :sys.get_state(MappingsCacher)
      assert Map.has_key?(state.mappings, @index_name_2)
    end
  end

  describe "delete/2" do
    import MappingsCacher, only: [delete: 1, get: 1]

    test "removes mapping from cache" do
      # Populate cache
      get(@index_name)

      # Delete from cache
      delete(@index_name)

      # Verify state
      state = :sys.get_state(MappingsCacher)

      refute Map.has_key?(state.mappings, @index_name)
    end
  end

  describe "clear/1" do
    import MappingsCacher, only: [clear: 0, get: 1]

    test "refreshes all mappings" do
      # Populate cache
      get(@index_name)

      # Create another index
      Client.request(:put, "/#{@index_name_2}", @mapping_2)

      # Clear cache
      clear()

      # Verify new mappings are loaded
      state = :sys.get_state(MappingsCacher)

      assert Map.has_key?(state.mappings, @index_name_2)
      assert Map.has_key?(state.mappings, @index_name)
    end
  end

  describe "expiration handling" do
    import MappingsCacher, only: [get: 1]

    test "cleans up expired mappings" do
      # Populate cache
      get(@index_name)

      # Simulate expired mapping by updating state
      state = :sys.get_state(MappingsCacher)

      expired_timestamp = current_timestamp() - :timer.seconds(60)

      mappings =
        Map.put(
          state.mappings,
          @index_name,
          {expired_timestamp, %{"properties" => %{"field" => %{"type" => "keyword"}}}}
        )

      :sys.replace_state(MappingsCacher, fn s -> %{s | mappings: mappings} end)

      # Trigger cleanup
      send(MappingsCacher, :clean_expired_mappings)
      # Allow async processing
      Process.sleep(100)

      # Verify mapping is refreshed
      state = :sys.get_state(MappingsCacher)
      {expiration, _mapping} = Map.get(state.mappings, @index_name)

      assert expiration > current_timestamp()
    end
  end

  ## Private functions

  defp current_timestamp do
    DateTime.utc_now(:millisecond) |> DateTime.to_unix(:millisecond)
  end
end
