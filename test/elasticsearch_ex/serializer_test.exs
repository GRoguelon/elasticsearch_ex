defmodule ElasticsearchEx.SerializerTest do
  use ExUnit.Case, async: true

  alias ElasticsearchEx.Serializer

  ## Module attributes

  @mappings %{
    "properties" => %{
      "keyword_field" => %{
        "type" => "keyword"
      }
    }
  }

  ## Setup

  setup do
    document = %{
      "_source" => %{
        "keyword_field" => "Hello World!"
      }
    }

    {:ok, document: document}
  end

  ## Tests

  test "returns a stream with a stream", %{document: document} do
    stream = Stream.map([document], & &1)
    result = Serializer.serialize(stream, @mappings)

    assert is_struct(result, Stream)
    assert Enum.count(result) == 1
  end

  test "returns a list with a list", %{document: document} do
    list = [document]
    result = Serializer.serialize(list, @mappings)

    assert is_list(result)
    assert length(result) == 1
  end

  test "returns a document with a document", %{document: document} do
    result = Serializer.serialize(document, @mappings)

    assert is_map(result)
    assert is_map_key(result, "_source")
    assert result == document
  end

  test "returns a document source with a document source", %{document: %{"_source" => source}} do
    result = Serializer.serialize(source, @mappings)

    assert is_map(result)
    assert is_map_key(result, "keyword_field")
    assert result["keyword_field"] == "Hello World!"
  end

  test "returns a base64 with a binary value" do
    result = Serializer.serialize("Hello World!", %{"type" => "binary"})

    assert result == "SGVsbG8gV29ybGQh"
  end

  test "returns a map with a integer_range value" do
    result = Serializer.serialize(1..10_000, %{"type" => "integer_range"})

    assert result == %{"gte" => 1, "lte" => 10_000}
  end

  test "returns a map with a long_range value" do
    result = Serializer.serialize(1..10_000, %{"type" => "long_range"})

    assert result == %{"gte" => 1, "lte" => 10_000}
  end

  test "returns a map with a date_range and strict_date value" do
    value = Date.range(~D[2024-02-06], ~D[2024-08-23])
    result = Serializer.serialize(value, %{"type" => "date_range", "format" => "strict_date"})

    assert result == %{"gte" => "2024-02-06", "lte" => "2024-08-23"}
  end

  test "returns a binary with a date and strict_date_time value" do
    value = ~U[2024-05-15 20:46:58.047143Z]
    result = Serializer.serialize(value, %{"type" => "date", "format" => "strict_date_time"})

    assert result == "2024-05-15T20:46:58.047143Z"
  end

  test "returns a binary with a date and strict_date value" do
    value = ~D[2024-05-15]
    result = Serializer.serialize(value, %{"type" => "date", "format" => "strict_date"})

    assert result == "2024-05-15"
  end

  test "returns list with list of values" do
    value = [1..2, 3..4]
    result = Serializer.serialize(value, %{"type" => "long_range"})

    assert result == [%{"gte" => 1, "lte" => 2}, %{"gte" => 3, "lte" => 4}]
  end

  test "returns any with any values" do
    assert Serializer.serialize(true, %{"type" => "boolean"}) == true
    assert Serializer.serialize("Hello", %{"type" => "keyword"}) == "Hello"
    assert Serializer.serialize(1, %{"type" => "byte"}) == 1
    assert Serializer.serialize(123, %{"type" => "short"}) == 123
    assert Serializer.serialize(1234, %{"type" => "integer"}) == 1234
    assert Serializer.serialize(1234, %{"type" => "long"}) == 1234
  end
end
