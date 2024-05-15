defmodule ElasticsearchEx.Deserializer do
  @moduledoc """
  Converts a document or source from Elasticsearch data structures into Elixir data structures.

  An example is the convertion of a range `%{"gte" => first, "lte" => last}` into Elixir `Range`
  or `Date.Range`.
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
  Deserialize a list of documents, a document or a document source.

  `Stream` is also accepted and returns a `Stream`.
  """
  @spec deserialize(value(), mappings()) :: value()
  def deserialize(value, mappings)

  def deserialize(stream, mapping) when is_struct(stream, Stream) do
    Stream.map(stream, &deserialize(&1, mapping))
  end

  def deserialize(values, mapping) when is_list(values) do
    Enum.map(values, &deserialize(&1, mapping))
  end

  def deserialize(%{"_source" => source} = document, mapping) do
    deserialized_source = deserialize(source, mapping)

    Map.put(document, "_source", deserialized_source)
  end

  def deserialize(value, %{"properties" => mapping}) when is_map(value) do
    Map.new(value, fn {key, value} ->
      key_mapping = Map.fetch!(mapping, key)
      deserialized_value = deserialize(value, key_mapping)

      {key, deserialized_value}
    end)
  end

  def deserialize(blob, %{"type" => "binary"}) when is_binary(blob) do
    case Base.decode64(blob) do
      {:ok, value} ->
        value

      :error ->
        blob
    end
  end

  def deserialize(%{"gte" => gte, "lte" => lte}, %{"type" => type})
      when type in ~w[integer_range long_range] do
    Range.new(gte, lte)
  end

  def deserialize(%{"gte" => gte, "lte" => lte} = value, %{
        "type" => "date_range",
        "format" => "strict_date"
      }) do
    with {:ok, first} <- Date.from_iso8601(gte),
         {:ok, last} <- Date.from_iso8601(lte) do
      Date.range(first, last)
    else
      _ ->
        value
    end
  end

  def deserialize(value, %{"type" => "date", "format" => "strict_date_time"}) do
    case DateTime.from_iso8601(value) do
      {:ok, date_time, 0} ->
        date_time

      _ ->
        value
    end
  end

  def deserialize(value, %{"type" => "date", "format" => "strict_date"}) do
    case Date.from_iso8601(value) do
      {:ok, date} ->
        date

      _ ->
        value
    end
  end

  def deserialize(value, _mapping) do
    value
  end
end
