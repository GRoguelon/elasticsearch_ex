defmodule ElasticsearchEx.DeserializerTest do
  use ExUnit.Case, async: true

  alias ElasticsearchEx.Deserializer

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
    result = Deserializer.deserialize(stream, @mappings)

    assert is_struct(result, Stream)
    assert Enum.count(result) == 1
  end

  test "returns a list with a list", %{document: document} do
    list = [document]
    result = Deserializer.deserialize(list, @mappings)

    assert is_list(result)
    assert length(result) == 1
  end

  test "returns a document with a document", %{document: document} do
    result = Deserializer.deserialize(document, @mappings)

    assert is_map(result)
    assert is_map_key(result, "_source")
    assert result == document
  end

  test "returns a document source with a document source", %{document: %{"_source" => source}} do
    result = Deserializer.deserialize(source, @mappings)

    assert is_map(result)
    assert is_map_key(result, "keyword_field")
    assert result["keyword_field"] == "Hello World!"
  end

  test "returns a binary value with a base64" do
    result = Deserializer.deserialize("SGVsbG8gV29ybGQh", %{"type" => "binary"})

    assert result == "Hello World!"
  end

  test "returns a integer_range value with a map" do
    result =
      Deserializer.deserialize(%{"gte" => 1, "lte" => 10_000}, %{"type" => "integer_range"})

    assert result == 1..10_000
  end

  test "returns a long_range value with a map" do
    result = Deserializer.deserialize(%{"gte" => 1, "lte" => 10_000}, %{"type" => "long_range"})

    assert result == 1..10_000
  end

  test "returns a date_range and strict_date value with a map" do
    result =
      Deserializer.deserialize(%{"gte" => "2024-02-06", "lte" => "2024-08-23"}, %{
        "type" => "date_range",
        "format" => "strict_date"
      })

    assert result == Date.range(~D[2024-02-06], ~D[2024-08-23])
  end

  test "returns a date and strict_date_time value with a binary" do
    result =
      Deserializer.deserialize("2024-05-15T20:46:58.047143Z", %{
        "type" => "date",
        "format" => "strict_date_time"
      })

    assert result == ~U[2024-05-15 20:46:58.047143Z]
  end

  test "returns a date and strict_date value with a binary" do
    result =
      Deserializer.deserialize("2024-05-15", %{"type" => "date", "format" => "strict_date"})

    assert result == ~D[2024-05-15]
  end

  test "returns list of values with list" do
    result =
      Deserializer.deserialize([%{"gte" => 1, "lte" => 2}, %{"gte" => 3, "lte" => 4}], %{
        "type" => "long_range"
      })

    assert result == [1..2, 3..4]
  end

  test "returns any with any values" do
    assert Deserializer.deserialize(true, %{"type" => "boolean"}) == true
    assert Deserializer.deserialize("Hello", %{"type" => "keyword"}) == "Hello"
    assert Deserializer.deserialize(1, %{"type" => "byte"}) == 1
    assert Deserializer.deserialize(123, %{"type" => "short"}) == 123
    assert Deserializer.deserialize(1234, %{"type" => "integer"}) == 1234
    assert Deserializer.deserialize(1234, %{"type" => "long"}) == 1234
  end
end
