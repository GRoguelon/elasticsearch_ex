defmodule ElasticsearchEx.Deserializer do
  @integer_range_types ~w[integer_range long_range]

  ## Public functions

  def deserialize_documents(stream, mapping) when is_struct(stream, Stream) do
    Stream.map(stream, &deserialize_document(&1, mapping))
  end

  def deserialize_documents(documents, mapping) when is_list(documents) do
    Enum.map(documents, &deserialize_document(&1, mapping))
  end

  def deserialize_document(%{"_source" => source} = document, mapping) do
    deserialized_source = deserialize_value(source, mapping)

    Map.put(document, "_source", deserialized_source)
  end

  @doc """
  Deserialize a value based on its mapping, if the value doesn't match, the original value is returned.
  """
  def deserialize_value(nil, _mapping), do: nil

  def deserialize_value(values, mapping) when is_list(values) do
    Enum.map(values, &deserialize_value(&1, mapping))
  end

  def deserialize_value(value, %{"properties" => mapping}) when is_map(value) do
    Map.new(value, fn {key, value} ->
      key_mapping = Map.fetch!(mapping, key)
      deserialized_value = deserialize_value(value, key_mapping)

      {key, deserialized_value}
    end)
  end

  ## Field types

  # https://www.elastic.co/guide/en/elasticsearch/reference/current/binary.html
  def deserialize_value(blob, %{"type" => "binary"}) do
    if is_binary(blob) do
      case Base.decode64(blob) do
        {:ok, value} ->
          value

        :error ->
          blob
      end
    end
  end

  # https://www.elastic.co/guide/en/elasticsearch/reference/current/range.html
  def deserialize_value(%{"gte" => gte, "lte" => lte}, %{"type" => type})
      when type in @integer_range_types and is_integer(gte) and is_integer(lte) do
    Range.new(gte, lte)
  end

  # https://www.elastic.co/guide/en/elasticsearch/reference/current/range.html
  def deserialize_value(%{"gte" => gte, "lte" => lte} = value, %{
        "type" => "date_range",
        "format" => "strict_date"
      })
      when is_binary(gte) and is_binary(lte) do
    with {:ok, first} <- Date.from_iso8601(gte),
         {:ok, last} <- Date.from_iso8601(lte) do
      Date.range(first, last)
    else
      _ ->
        value
    end
  end

  # https://www.elastic.co/guide/en/elasticsearch/reference/current/date.html
  def deserialize_value(value, %{"type" => "date", "format" => "strict_date_time"}) do
    case DateTime.from_iso8601(value) do
      {:ok, date_time, 0} ->
        date_time

      _ ->
        value
    end
  end

  # https://www.elastic.co/guide/en/elasticsearch/reference/current/date.html
  def deserialize_value(value, %{"type" => "date", "format" => "strict_date"}) do
    case Date.from_iso8601(value) do
      {:ok, date} ->
        date

      _ ->
        value
    end
  end

  def deserialize_value(value, _mapping) do
    value
  end
end
