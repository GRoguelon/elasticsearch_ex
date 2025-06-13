defmodule ElasticsearchEx.DeserializerTest do
  use ExUnit.Case, async: true

  ## Tests

  describe "deserialize/3" do
    import ElasticsearchEx.Deserializer, only: [deserialize: 2, deserialize: 3]

    test "deserializes a stream of documents" do
      document = %{"_index" => "test", "_source" => %{"field" => "SGVsbG8="}}
      mapping = %{"properties" => %{"field" => %{"type" => "binary"}}}
      stream = Stream.map([document], & &1)

      result = deserialize(stream, mapping) |> Enum.to_list()
      assert [%{"_index" => "test", "_source" => %{"field" => "Hello"}}] = result
    end

    test "deserializes a list of documents" do
      document = %{"_index" => "test", "_source" => %{"field" => "SGVsbG8="}}
      mapping = %{"properties" => %{"field" => %{"type" => "binary"}}}

      result = deserialize([document], mapping)
      assert [%{"_index" => "test", "_source" => %{"field" => "Hello"}}] = result
    end

    test "deserializes hits structure" do
      hits = %{
        "hits" => %{"hits" => [%{"_index" => "test", "_source" => %{"field" => "SGVsbG8="}}]}
      }

      mapping = %{"properties" => %{"field" => %{"type" => "binary"}}}

      result = deserialize(hits, mapping)

      assert %{"hits" => %{"hits" => [%{"_index" => "test", "_source" => %{"field" => "Hello"}}]}} =
               result
    end

    test "deserializes a single document with key transformation" do
      document = %{"_index" => "test", "_source" => %{"field" => "SGVsbG8="}}
      mapping = %{"properties" => %{"field" => %{"type" => "binary"}}}

      result = deserialize(document, mapping, &String.to_atom/1)
      assert %{"_index" => "test", "_source" => %{field: "Hello"}} = result
    end

    test "uses mapper function for mappings" do
      document = %{"_index" => "test", "_source" => %{"field" => "SGVsbG8="}}
      mapper = fn "test" -> %{"properties" => %{"field" => %{"type" => "binary"}}} end

      result = deserialize(document, mapper)
      assert %{"_index" => "test", "_source" => %{"field" => "Hello"}} = result
    end

    test "raises for invalid mapper" do
      document = %{"_index" => "test", "_source" => %{"field" => "value"}}

      assert_raise ArgumentError, "mapper argument must be a map or a function of arity 1", fn ->
        deserialize(document, %{"invalid" => "map"})
      end
    end
  end

  describe "deserialize_field/3" do
    import ElasticsearchEx.Deserializer, only: [deserialize_field: 2, deserialize_field: 3]

    test "deserializes list of values" do
      mapping = %{"type" => "binary"}
      result = deserialize_field(["SGVsbG8=", "d29ybGQ="], mapping)
      assert ["Hello", "world"] = result
    end

    test "deserializes nested map with properties" do
      mapping = %{
        "properties" => %{
          "field" => %{"type" => "binary"},
          "nested" => %{"properties" => %{"subfield" => %{"type" => "text"}}}
        }
      }

      value = %{"field" => "SGVsbG8=", "nested" => %{"subfield" => "value"}}
      result = deserialize_field(value, mapping, &String.to_atom/1)
      assert %{field: "Hello", nested: %{subfield: "value"}} = result
    end

    test "deserializes binary field" do
      assert deserialize_field("SGVsbG8=", %{"type" => "binary"}) == "Hello"
      assert deserialize_field("invalid", %{"type" => "binary"}) == "invalid"
    end

    test "deserializes integer_range and long_range" do
      mapping = %{"type" => "integer_range"}
      assert deserialize_field(%{"gte" => 1, "lte" => 10}, mapping) == 1..10

      mapping = %{"type" => "long_range"}
      assert deserialize_field(%{"gte" => 100, "lte" => 1000}, mapping) == 100..1000
    end

    test "deserializes date_range with strict_date format" do
      mapping = %{"type" => "date_range", "format" => "strict_date"}
      value = %{"gte" => "2023-01-01", "lte" => "2023-01-02"}
      result = deserialize_field(value, mapping)
      assert %Date.Range{first: ~D[2023-01-01], last: ~D[2023-01-02]} = result

      # Invalid date
      assert deserialize_field(%{"gte" => "invalid", "lte" => "2023-01-02"}, mapping) ==
               %{"gte" => "invalid", "lte" => "2023-01-02"}
    end

    test "deserializes date with strict_date format" do
      mapping = %{"type" => "date", "format" => "strict_date"}
      assert deserialize_field("2023-01-01", mapping) == ~D[2023-01-01]
      assert deserialize_field("invalid", mapping) == "invalid"
    end

    test "deserializes date with strict_date_time format" do
      mapping = %{"type" => "date", "format" => "strict_date_time"}
      assert deserialize_field("2023-01-01T12:00:00Z", mapping) == ~U[2023-01-01 12:00:00Z]
      assert deserialize_field("invalid", mapping) == "invalid"
    end

    test "returns unchanged for unmatched mapping" do
      assert deserialize_field("value", %{"type" => "text"}) == "value"
      assert deserialize_field(123, %{"type" => "integer"}) == 123
      assert deserialize_field(nil, %{"type" => "keyword"}) == nil
    end
  end
end
