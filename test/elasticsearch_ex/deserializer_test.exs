defmodule ElasticsearchEx.DeserializerTest do
  use ExUnit.Case, async: true

  alias ElasticsearchEx.Deserializer

  ## Tests

  setup_all do
    pid = Process.whereis(ElasticsearchEx.MappingsCacher)
    clusters = Application.get_env(:elasticsearch_ex, :clusters)
    on_exit(fn -> Application.put_env(:elasticsearch_ex, :clusters, clusters) end)

    # Set up application config
    Application.put_env(:elasticsearch_ex, :clusters, %{
      default: %{
        endpoint: "http://localhost:9200",
        req_opts: [plug: {Req.Test, ElasticsearchEx.ClientStub}]
      }
    })

    Req.Test.stub(ElasticsearchEx.ClientStub, fn %Plug.Conn{
                                                   method: "GET",
                                                   request_path: "/test/_mapping"
                                                 } = conn ->
      Req.Test.json(conn, %{
        "test" => %{"mappings" => %{"properties" => %{"field" => %{"type" => "binary"}}}}
      })
    end)

    Req.Test.allow(ElasticsearchEx.ClientStub, self(), pid)

    :ok
  end

  describe "deserialize/2 and /3" do
    test "deserializes a stream of documents" do
      doc = %{"_index" => "test", "_source" => %{"field" => "SGVsbG8="}}
      stream = Stream.map([doc], &Function.identity/1)
      result = Deserializer.deserialize(stream) |> Enum.to_list()

      assert [%{"_index" => "test", "_source" => %{"field" => "Hello"}}] = result
    end

    test "deserializes a list of documents" do
      doc = %{"_index" => "test", "_source" => %{"field" => "SGVsbG8="}}
      result = Deserializer.deserialize([doc])

      assert [%{"_index" => "test", "_source" => %{"field" => "Hello"}}] = result
    end

    test "deserializes hits structure" do
      hits = %{
        "hits" => %{"hits" => [%{"_index" => "test", "_source" => %{"field" => "SGVsbG8="}}]}
      }

      result = Deserializer.deserialize(hits)

      assert %{"hits" => %{"hits" => [%{"_index" => "test", "_source" => %{"field" => "Hello"}}]}} =
               result
    end

    test "deserializes a single document with key transformation" do
      doc = %{"_index" => "test", "_source" => %{"field" => "SGVsbG8="}}
      result = Deserializer.deserialize(doc, &String.to_atom/1)

      assert %{_index: "test", _source: %{field: "Hello"}} = result
    end

    test "deserializes a plain map with key transformation" do
      doc = %{"foo" => "bar"}
      result = Deserializer.deserialize(doc, &String.to_atom/1)

      assert %{foo: "bar"} = result
    end
  end

  describe "deserialize_field/3" do
    test "deserializes a list of binary values" do
      mapping = %{"type" => "binary"}

      assert ["Hello", "world"] =
               Deserializer.deserialize_field(["SGVsbG8=", "d29ybGQ="], mapping)
    end

    test "deserializes nested map with properties and key mapping" do
      mapping = %{
        "properties" => %{
          "field" => %{"type" => "binary"},
          "nested" => %{"properties" => %{"subfield" => %{"type" => "text"}}}
        }
      }

      value = %{"field" => "SGVsbG8=", "nested" => %{"subfield" => "value"}}
      result = Deserializer.deserialize_field(value, mapping, &String.to_atom/1)
      assert %{field: "Hello", nested: %{subfield: "value"}} = result
    end

    test "deserializes binary field and handles invalid base64" do
      assert Deserializer.deserialize_field("SGVsbG8=", %{"type" => "binary"}) == "Hello"
      assert Deserializer.deserialize_field("invalid", %{"type" => "binary"}) == "invalid"
    end

    test "deserializes integer_range and long_range" do
      assert Deserializer.deserialize_field(%{"gte" => 1, "lte" => 10}, %{
               "type" => "integer_range"
             }) == 1..10

      assert Deserializer.deserialize_field(%{"gte" => 100, "lte" => 1000}, %{
               "type" => "long_range"
             }) == 100..1000
    end

    test "deserializes date_range with strict_date format and handles invalid dates" do
      mapping = %{"type" => "date_range", "format" => "strict_date"}
      value = %{"gte" => "2023-01-01", "lte" => "2023-01-02"}

      assert %Date.Range{first: ~D[2023-01-01], last: ~D[2023-01-02]} =
               Deserializer.deserialize_field(value, mapping)

      assert Deserializer.deserialize_field(%{"gte" => "invalid", "lte" => "2023-01-02"}, mapping) ==
               %{"gte" => "invalid", "lte" => "2023-01-02"}
    end

    test "deserializes date with strict_date and strict_date_time formats" do
      assert Deserializer.deserialize_field("2023-01-01", %{
               "type" => "date",
               "format" => "strict_date"
             }) == ~D[2023-01-01]

      assert Deserializer.deserialize_field("2023-01-01T12:00:00Z", %{
               "type" => "date",
               "format" => "strict_date_time"
             }) == ~U[2023-01-01 12:00:00Z]

      assert Deserializer.deserialize_field("invalid", %{
               "type" => "date",
               "format" => "strict_date"
             }) == "invalid"

      assert Deserializer.deserialize_field("invalid", %{
               "type" => "date",
               "format" => "strict_date_time"
             }) == "invalid"
    end

    test "returns unchanged for unmatched mapping" do
      assert Deserializer.deserialize_field("value", %{"type" => "text"}) == "value"
      assert Deserializer.deserialize_field(123, %{"type" => "integer"}) == 123
      assert Deserializer.deserialize_field(nil, %{"type" => "keyword"}) == nil
    end
  end
end
