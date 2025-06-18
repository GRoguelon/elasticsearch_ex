defmodule ElasticsearchEx.Deserializer do
  @moduledoc """
  Utilities for converting Elasticsearch documents and responses into idiomatic Elixir data structures.

  This module provides functions to transform Elasticsearch data—such as documents, sources, or hits—into Elixir types, handling type conversions based on provided mappings. It supports nested structures, lists, and streams, and allows for custom key transformation.

  ## Features

    * Converts string-keyed Elasticsearch maps into Elixir maps, optionally transforming keys (e.g., to atoms).
    * Deserializes special Elasticsearch types:
      - `"binary"`: Decodes base64-encoded strings.
      - `"integer_range"`, `"long_range"`: Converts range objects to `Range.t()`.
      - `"date_range"`: Converts date range objects to `Date.Range.t()` (for `"strict_date"` format).
      - `"date"`: Converts date strings to `Date.t()` or `DateTime.t()` (for `"strict_date"` or `"strict_date_time"` formats).
    * Handles streams, lists, and single documents.
    * Gracefully falls back to original values for invalid or unrecognized formats.

  ## Example Usage

      # Basic document deserialization
      iex(1)> doc = %{"_index" => "test", "_source" => %{"date" => "2023-01-01"}}
      iex(2)> ElasticsearchEx.Deserializer.deserialize(doc, &Function.identity/1)
      %{"_index" => "test", "_source" => %{"date" => ~D[2023-01-01]}}

      # Stream deserialization
      iex(1)> stream = Stream.map([doc], & &1)
      iex(2)> Stream.run(ElasticsearchEx.Deserializer.deserialize(stream, &Function.identity/1))
      [%{_index: "test", _source: %{date: ~D[2023-01-01]}}]

      # Custom key function (e.g., to atoms)
      iex> ElasticsearchEx.Deserializer.deserialize(doc, &String.to_atom/1)
      %{_index: "test", _source: %{date: ~D[2023-01-01]}}
  """

  alias ElasticsearchEx.MapExt
  alias ElasticsearchEx.MappingsCacher

  require Logger

  ## Module attributes

  @typedoc """
  Elasticsearch mappings describing field types and formats.
  Should contain a `"properties"` key when provided as a map.
  """
  @type mappings :: %{required(binary()) => any()}

  @typedoc """
  Input data to be deserialized: a stream, list of documents, a single document, a document source, or a field value.
  """
  @type value :: Enumerable.t() | %{required(binary()) => any()}

  ## Public functions

  @doc """
  Deserializes Elasticsearch documents, sources, or streams into Elixir data structures.

  Accepts a stream, list, single document, or source map. Optionally, a `key_mapper` function can be provided to transform map keys (defaults to identity).

  Returns:
    * A stream for stream input
    * A list for list input
    * A map for document/source input

  ## Examples

      # Document deserialization
      iex(1)> doc = %{"_index" => "test", "_source" => %{"field" => "data"}}
      iex(2)> ElasticsearchEx.Deserializer.deserialize(doc)
      %{"_index" => "test", "_source" => %{"field" => "data"}}

      # With key transformation
      iex> ElasticsearchEx.Deserializer.deserialize(doc, &String.to_atom/1)
      %{_index: "test", _source: %{field: "data"}}

      # Graceful handling of invalid dates
      iex(1)> doc = %{"_index" => "test", "_source" => %{"date" => "invalid"}}
      iex(2)> ElasticsearchEx.Deserializer.deserialize(doc)
      %{"_index" => "test", "_source" => %{"date" => "invalid"}}
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

  def deserialize(document, key_mapper) when is_map(document),
    do: MapExt.map_keys(document, key_mapper)

  def deserialize(document, _key_mapper), do: document

  @doc """
  Deserializes a field value according to its Elasticsearch mapping.

  Handles lists, nested maps (with `"properties"`), and scalar values. Supports special types such as `"binary"`, `"integer_range"`, `"long_range"`, `"date_range"`, and `"date"` (with format).

  If the value or mapping does not match a supported type or format, the original value is returned.

  ## Examples

      # Binary field
      iex> ElasticsearchEx.Deserializer.deserialize_field("SGVsbG8=", %{"type" => "binary"})
      "Hello"

      # Date range field
      iex> ElasticsearchEx.Deserializer.deserialize_field(
      ...>   %{"gte" => "2023-01-01", "lte" => "2023-01-02"},
      ...>   %{"type" => "date_range", "format" => "strict_date"},
      ...> )
      #Date.Range<...>
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
