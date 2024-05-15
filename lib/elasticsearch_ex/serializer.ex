defmodule ElasticsearchEx.Serializer do
  ## Public functions

  def serialize_documents(stream, mapping) when is_struct(stream, Stream) do
    Stream.map(stream, &serialize_document(&1, mapping))
  end

  def serialize_documents(documents, mapping) when is_list(documents) do
    Enum.map(documents, &serialize_document(&1, mapping))
  end

  def serialize_document(%{"_source" => source} = document, mapping) do
    serialized_source = serialize_value(source, mapping)

    Map.put(document, "_source", serialized_source)
  end

  @doc """
  Deserialize a value based on its mapping, if the value doesn't match, the original value is returned.
  """
  def serialize_value(nil, _mapping), do: nil

  def serialize_value(values, mapping) when is_list(values) do
    Enum.map(values, &serialize_value(&1, mapping))
  end

  def serialize_value(value, %{"properties" => mapping}) when is_map(value) do
    Map.new(value, fn {key, value} ->
      key_mapping = Map.fetch!(mapping, key)
      serialized_value = serialize_value(value, key_mapping)

      {key, serialized_value}
    end)
  end

  ## Field types

  # https://www.elastic.co/guide/en/elasticsearch/reference/current/binary.html
  def serialize_value(value, %{"type" => "binary"})
      when is_binary(value) and byte_size(value) > 0 do
    Base.encode64(value)
  end

  # https://www.elastic.co/guide/en/elasticsearch/reference/current/range.html
  def serialize_value(%Range{first: first, last: last}, %{"type" => type})
      when type in ~w[integer_range long_range] do
    %{"gte" => first, "lte" => last}
  end

  # https://www.elastic.co/guide/en/elasticsearch/reference/current/range.html
  def serialize_value(%Date.Range{first: first, last: last}, %{
        "type" => "date_range",
        "format" => "strict_date"
      }) do
    %{
      "gte" => Date.to_iso8601(first),
      "lte" => Date.to_iso8601(last)
    }
  end

  # https://www.elastic.co/guide/en/elasticsearch/reference/current/date.html
  def serialize_value(%DateTime{} = date_time, %{"type" => "date", "format" => "strict_date_time"}) do
    DateTime.to_iso8601(date_time)
  end

  # https://www.elastic.co/guide/en/elasticsearch/reference/current/date.html
  def serialize_value(%Date{} = date, %{"type" => "date", "format" => "strict_date"}) do
    Date.to_iso8601(date)
  end

  @default_function Application.compile_env(:elasticsearch_ex, :serializer)

  if @default_function do
    def serialize_value(value, mapping) do
      @default_function.(value, mapping)
    end
  else
    def serialize_value(value, _mapping) do
      value
    end
  end
end
