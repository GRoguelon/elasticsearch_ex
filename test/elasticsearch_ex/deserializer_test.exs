defmodule ElasticsearchEx.DeserializerTest do
  use ExUnit.Case, async: true

  alias ElasticsearchEx.Deserializer

  ## Module attributes

  @mappings %{
    "properties" => %{
      "keyword_field" => %{
        "type" => "keyword"
      },
      "binary_field" => %{
        "type" => "binary"
      }
    }
  }

  @serialized_doc_as_str %{
    "_source" => %{
      "keyword_field" => "Hello World!",
      "binary_field" => "TG9yZW0gaXBzdW0gZG9sb3Igc2l0IGFtZXQu"
    }
  }

  @deserialized_doc_as_str %{
    "_source" => %{
      "binary_field" => "Lorem ipsum dolor sit amet.",
      "keyword_field" => "Hello World!"
    }
  }

  @serialized_doc_as_atom @serialized_doc_as_str |> Jason.encode!() |> Jason.decode!(keys: :atoms)

  @deserialized_doc_as_atom @deserialized_doc_as_str
                            |> Jason.encode!()
                            |> Jason.decode!(keys: :atoms)

  @binary_type %{"type" => "binary"}

  @integer_range_type %{"type" => "integer_range"}

  @long_range_type %{"type" => "long_range"}

  @date_range_type %{"type" => "date_range", "format" => "strict_date"}

  @date_time_type %{"type" => "date", "format" => "strict_date_time"}

  @date_type %{"type" => "date", "format" => "strict_date"}

  ## Tests

  test "returns nil with nil" do
    result = Deserializer.deserialize(nil, @mappings)

    assert is_nil(result)
  end

  test "returns a stream with a stream" do
    stream = Stream.map([@serialized_doc_as_str], & &1)
    result = Deserializer.deserialize(stream, @mappings)

    assert is_struct(result, Stream)
    assert Enum.count(result) == 1
  end

  test "returns a list with a list" do
    list = [@serialized_doc_as_str]
    result = Deserializer.deserialize(list, @mappings)

    assert is_list(result)
    assert length(result) == 1
  end

  test "returns a document with a document as atoms" do
    result = Deserializer.deserialize(@serialized_doc_as_atom, @mappings)

    assert is_map(result)
    assert is_map_key(result, :_source)

    assert result == @deserialized_doc_as_atom
  end

  test "returns a document with a document" do
    result = Deserializer.deserialize(@serialized_doc_as_str, @mappings)

    assert is_map(result)
    assert is_map_key(result, "_source")

    assert result == @deserialized_doc_as_str
  end

  test "returns a document source with a document source as atoms" do
    result = Deserializer.deserialize(@serialized_doc_as_atom[:_source], @mappings)

    assert is_map(result)
    assert is_map_key(result, :keyword_field)

    assert result == @deserialized_doc_as_atom[:_source]
  end

  test "returns a document source with a document source" do
    result = Deserializer.deserialize(@serialized_doc_as_str["_source"], @mappings)

    assert is_map(result)
    assert is_map_key(result, "keyword_field")

    assert result == @deserialized_doc_as_str["_source"]
  end

  test "returns a binary value with a base64" do
    result = Deserializer.deserialize("SGVsbG8gV29ybGQh", @binary_type)

    assert result == "Hello World!"
  end

  test "returns a integer_range value with a map as atoms" do
    result = Deserializer.deserialize(%{gte: 1, lte: 10_000}, @integer_range_type)

    assert result == 1..10_000
  end

  test "returns a integer_range value with a map" do
    result = Deserializer.deserialize(%{"gte" => 1, "lte" => 10_000}, @integer_range_type)

    assert result == 1..10_000
  end

  test "returns a long_range value with a map as atoms" do
    result = Deserializer.deserialize(%{gte: 1, lte: 10_000}, @long_range_type)

    assert result == 1..10_000
  end

  test "returns a long_range value with a map" do
    result = Deserializer.deserialize(%{"gte" => 1, "lte" => 10_000}, @long_range_type)

    assert result == 1..10_000
  end

  test "returns a date_range and strict_date value with a map as atoms" do
    result = Deserializer.deserialize(%{gte: "2024-02-06", lte: "2024-08-23"}, @date_range_type)

    assert result == Date.range(~D[2024-02-06], ~D[2024-08-23])
  end

  test "returns a date_range and strict_date value with a map" do
    result =
      Deserializer.deserialize(%{"gte" => "2024-02-06", "lte" => "2024-08-23"}, @date_range_type)

    assert result == Date.range(~D[2024-02-06], ~D[2024-08-23])
  end

  test "returns a date and strict_date_time value with a binary" do
    result = Deserializer.deserialize("2024-05-15T20:46:58.047143Z", @date_time_type)

    assert result == ~U[2024-05-15 20:46:58.047143Z]
  end

  test "returns a date and strict_date value with a binary" do
    result = Deserializer.deserialize("2024-05-15", @date_type)

    assert result == ~D[2024-05-15]
  end

  test "returns list of values with list as atoms" do
    result = Deserializer.deserialize([%{gte: 1, lte: 2}, %{gte: 3, lte: 4}], @long_range_type)

    assert result == [1..2, 3..4]
  end

  test "returns list of values with list" do
    result =
      Deserializer.deserialize(
        [%{"gte" => 1, "lte" => 2}, %{"gte" => 3, "lte" => 4}],
        @long_range_type
      )

    assert result == [1..2, 3..4]
  end

  test "returns any with any values" do
    assert Deserializer.deserialize(nil, %{"type" => "boolean"}) == nil
    assert Deserializer.deserialize(true, %{"type" => "boolean"}) == true
    assert Deserializer.deserialize("Hello", %{"type" => "keyword"}) == "Hello"
    assert Deserializer.deserialize(1, %{"type" => "byte"}) == 1
    assert Deserializer.deserialize(123, %{"type" => "short"}) == 123
    assert Deserializer.deserialize(1234, %{"type" => "integer"}) == 1234
    assert Deserializer.deserialize(1234, %{"type" => "long"}) == 1234
  end
end
