defmodule ElasticsearchEx.NdjsonTest do
  use ExUnit.Case, async: true

  alias ElasticsearchEx.Ndjson

  @encoded_ndjson ~s<{"a":"b"}\n{"c":"d"}\n>
  @decoded_ndjson [%{"a" => "b"}, %{"c" => "d"}]

  describe "encode!/1" do
    test "returns a string" do
      assert Ndjson.encode!(@decoded_ndjson) == @encoded_ndjson
    end

    test "raises an exception if any item is not a valid JSON encodable value" do
      # Tuples are unsupported by Jason.
      assert_raise Protocol.UndefinedError, fn ->
        Ndjson.encode!([%{"a" => {"b", "b"}}, %{"c" => {"d", "d"}}])
      end
    end
  end

  describe "decode!/1" do
    test "returns a term" do
      assert Ndjson.decode!(@encoded_ndjson) == @decoded_ndjson
    end

    test "raises an exception if the string is no valid NDJSON" do
      # Without a newline separating 2 lines
      assert_raise Jason.DecodeError, fn ->
        Ndjson.decode!(~s<{"a":"b"}{"c":"d"}\n>)
      end

      # With broken JSON
      assert_raise Jason.DecodeError, fn ->
        Ndjson.decode!(~s<{"a":"b}\n{"c":"d"}\n>)
      end
    end
  end
end
