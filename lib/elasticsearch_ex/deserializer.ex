defmodule ElasticsearchEx.Deserializer do
  @moduledoc """
  Converts Elasticsearch data structures (documents, sources, or hits) into Elixir data structures.

  This module deserializes Elasticsearch responses, transforming string-keyed maps into Elixir types
  such as `Range`, `Date.Range`, `Date`, or `DateTime` based on the provided mappings. It supports
  nested maps, lists, and streams, and allows custom key transformation via a `key_mapper`.

  ## Supported Types
  - `"binary"`: Decodes base64-encoded strings.
  - `"integer_range"`, `"long_range"`: Converts `%{gte: int, lte: int}` to `Range.t()`.
  - `"date_range"`: Converts `%{gte: date_str, lte: date_str}` to `Date.Range.t()` for `"strict_date"` format.
  - `"date"`: Converts strings to `Date.t()` or `DateTime.t()` for `"strict_date"` or `"strict_date_time"` formats.

  ## Examples
      # Deserialize a document with a date field
      document = %{"_index" => "test", "_source" => %{"date" => "2023-01-01"}}
      mapping = %{"properties" => %{"date" => %{"type" => "date", "format" => "strict_date"}}}
      deserialize(document, mapping)
      # => %{"_index" => "test", "_source" => %{"date" => ~D[2023-01-01]}}

      # Deserialize a stream of documents
      stream = Stream.map([document], & &1)
      Stream.run(deserialize(stream, mapping))
  """

  alias ElasticsearchEx.MapExt
  alias ElasticsearchEx.MappingsCacher

  require Logger

  ## Module attributes

  @typedoc """
  Elasticsearch mappings, a map with string keys describing field types and formats.

  Must contain a `"properties"` key when provided as a map.
  """
  @type mappings :: %{required(binary()) => any()}

  @typedoc """
  Input data: a stream, list of documents, a single document, a document source, or a field value.

  Documents are maps with `"_index"` and `"_source"` keys. Sources are string-keyed maps.
  """
  @type value :: Enumerable.t() | %{required(binary()) => any()}

  ## Public functions

  @doc """
  Deserializes a list of documents, a single document, a document source, or a stream.

  - `value`: The input data (stream, list, document, or source map).
  - `key_mapper`: A function to transform keys in deserialized maps (defaults to `Function.identity/1`).

  Returns a stream for stream input, a list for list input, or a map for document/source input.

  ## Examples
      # Deserialize a document
      document = %{"_index" => "test", "_source" => %{"field" => "data"}}
      mapping = %{"properties" => %{"field" => %{"type" => "text"}}}
      deserialize(document, mapping)
      # => %{"_index" => "test", "_source" => %{"field" => "data"}}

      # With key transformation
      deserialize(document, mapping, &String.to_atom/1)
      # => %{"_index" => "test", "_source" => %{field: "data"}}

      # Handle invalid date gracefully
      document = %{"_index" => "test", "_source" => %{"date" => "invalid"}}
      mapping = %{"properties" => %{"date" => %{"type" => "date", "format" => "strict_date"}}}
      deserialize(document, mapping)
      # => %{"_index" => "test", "_source" => %{"date" => "invalid"}}
  """
  @spec deserialize(value(), (binary() -> any())) :: value()
  def deserialize(value, key_mapper \\ &Function.identity/1)

  def deserialize(stream, key_mapper) when is_struct(stream, Stream) do
    Stream.map(stream, &deserialize(&1, key_mapper))
  end

  def deserialize(values, key_mapper) when is_list(values) do
    Enum.map(values, &deserialize(&1, key_mapper))
  end

  @key_accesses ~w[hits hits]

  def deserialize(%{"hits" => %{"hits" => _hits}} = result, key_mapper) do
    {hits, result} = pop_in(result, @key_accesses)
    atomized_result = MapExt.map_keys(result, key_mapper)
    deserialized_hits = deserialize(hits, key_mapper)
    key_accesses = Enum.map(@key_accesses, key_mapper)

    put_in(atomized_result, key_accesses, deserialized_hits)
  end

  def deserialize(%{"_index" => index, "_source" => _source} = document, key_mapper) do
    mapping = MappingsCacher.get(index)
    {source, document} = Map.pop!(document, "_source")
    atomized_document = MapExt.map_keys(document, key_mapper)
    deserialized_source = deserialize_field(source, mapping, key_mapper)
    mapped_key = key_mapper.("_source")

    Map.put(atomized_document, mapped_key, deserialized_source)
  end

  def deserialize(document, key_mapper), do: MapExt.map_keys(document, key_mapper)

  @doc """
  Deserializes a field value based on its Elasticsearch mapping.

  - `value`: The field value (map, list, or scalar).
  - `mapping`: The field’s mapping, typically containing `"type"` and optional `"format"`.
  - `key_mapper`: A function to transform keys in deserialized maps (defaults to `Function.identity/1`).

  Supports specific types like `"binary"`, `"integer_range"`, `"long_range"`, `"date_range"`,
  and `"date"`. Non-matching values or invalid formats are returned unchanged.

  ## Examples
      # Deserialize a binary field
      deserialize_field("SGVsbG8=", %{"type" => "binary"})
      # => "Hello"

      # Deserialize a date range
      deserialize_field(%{"gte" => "2023-01-01", "lte" => "2023-01-02"}, %{
        "type" => "date_range",
        "format" => "strict_date"
      })
      # => Date.Range.t()
  """
  @spec deserialize_field(any(), mappings(), (binary() -> any())) :: any()
  def deserialize_field(value, mapping, key_mapper \\ &Function.identity/1)

  def deserialize_field(value, mapping, key_mapper) when is_list(value) do
    Enum.map(value, &deserialize_field(&1, mapping, key_mapper))
  end

  def deserialize_field(value, %{"properties" => mapping}, key_mapper) when is_map(value) do
    Map.new(value, fn {key, value} ->
      key_mapping = Map.fetch!(mapping, key)
      deserialized_value = deserialize_field(value, key_mapping, key_mapper)

      {key_mapper.(key), deserialized_value}
    end)
  end

  def deserialize_field(blob, %{"type" => "binary"}, _) when is_binary(blob) do
    case Base.decode64(blob) do
      {:ok, value} ->
        value

      :error ->
        blob
    end
  end

  def deserialize_field(%{"gte" => gte, "lte" => lte}, %{"type" => type}, _)
      when type in ~w[integer_range long_range] do
    Range.new(gte, lte)
  end

  def deserialize_field(
        %{"gte" => gte, "lte" => lte} = value,
        %{
          "type" => "date_range",
          "format" => "strict_date"
        },
        _keys_atoms
      ) do
    with {:ok, first} <- Date.from_iso8601(gte),
         {:ok, last} <- Date.from_iso8601(lte) do
      Date.range(first, last)
    else
      _ ->
        value
    end
  end

  def deserialize_field(value, %{"type" => "date", "format" => "strict_date_time"}, _)
      when is_binary(value) do
    case DateTime.from_iso8601(value) do
      {:ok, date_time, 0} ->
        date_time

      _ ->
        value
    end
  end

  def deserialize_field(value, %{"type" => "date", "format" => "strict_date"}, _)
      when is_binary(value) do
    case Date.from_iso8601(value) do
      {:ok, date} ->
        date

      _ ->
        value
    end
  end

  def deserialize_field(value, _mapping, _) do
    value
  end
end
