defmodule ElasticsearchEx.Serializer do
  @moduledoc """
  Converts a document or source from Elixir data structures into data structures compatible with
  Elasticsearch.

  An example is the convertion of `Range` or `Date.Range` into `%{"gte" => first, "lte" => last}`.
  """

  ## Module attributes

  @typedoc """
  Represents the Elasticsearch mappings which is represented by a `Map` with keys as `String`.
  """
  @type mappings :: %{required(binary()) => any()}

  @typedoc """
  Represents a list/stream of documents, a document, a document source or any values.
  """
  @type value :: Enumerable.t() | %{required(binary()) => any()}

  ## Public functions

  @doc """
  Serialize a list of documents, a document or a document source.

  `Stream` is also accepted and returns a `Stream`.
  """
  @spec serialize(value(), mappings()) :: value()
  def serialize(value, mappings)

  def serialize(stream, mapping) when is_struct(stream, Stream) do
    Stream.map(stream, &serialize(&1, mapping))
  end

  def serialize(documents, mapping) when is_list(documents) do
    Enum.map(documents, &serialize(&1, mapping))
  end

  def serialize(%{"_source" => source} = document, mapping) do
    serialized_source = serialize(source, mapping)

    Map.put(document, "_source", serialized_source)
  end

  def serialize(value, %{"properties" => mapping}) when is_map(value) do
    Map.new(value, fn {key, value} ->
      key_mapping = Map.fetch!(mapping, key)
      serialized_value = serialize(value, key_mapping)

      {key, serialized_value}
    end)
  end

  def serialize(value, %{"type" => "binary"}) when is_binary(value) and byte_size(value) > 0 do
    Base.encode64(value)
  end

  def serialize(%Range{first: first, last: last}, %{"type" => type})
      when type in ~w[integer_range long_range] do
    %{"gte" => first, "lte" => last}
  end

  def serialize(%Date.Range{first: first, last: last}, %{
        "type" => "date_range",
        "format" => "strict_date"
      }) do
    %{
      "gte" => Date.to_iso8601(first),
      "lte" => Date.to_iso8601(last)
    }
  end

  def serialize(%DateTime{} = date_time, %{"type" => "date", "format" => "strict_date_time"}) do
    DateTime.to_iso8601(date_time)
  end

  def serialize(%Date{} = date, %{"type" => "date", "format" => "strict_date"}) do
    Date.to_iso8601(date)
  end

  def serialize(value, _mapping) do
    value
  end
end
