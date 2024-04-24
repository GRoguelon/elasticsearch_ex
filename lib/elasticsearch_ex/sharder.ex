defmodule ElasticsearchEx.Sharder do
  @moduledoc """
  This module allows you to fetch a subset of documents from an Elasticsearch index. It uses a
  modulo operation on the document ID to determine the shard number.
  """

  ## Module attributes

  @alphabets %{
    base64:
      ~w[A B C D E F G H I J K L M N O P Q R S T U V W X Y Z a b c d e f g h i j k l m n o p q r s t u v w x y z 0 1 2 3 4 5 6 7 8 9 + /],
    safe_base64:
      ~w[A B C D E F G H I J K L M N O P Q R S T U V W X Y Z a b c d e f g h i j k l m n o p q r s t u v w x y z 0 1 2 3 4 5 6 7 8 9 - _]
  }

  ## Public functions

  def shard(query, nbr_shards) do
    do_shard(query, nbr_shards, nil, [])
  end

  def shard(query, nbr_shards, shard_number) when is_integer(shard_number) do
    do_shard(query, nbr_shards, shard_number, [])
  end

  def shard(query, nbr_shards, opts) when is_list(opts) do
    do_shard(query, nbr_shards, nil, opts)
  end

  def shard(query, nbr_shards, shard_number, opts)
      when is_integer(shard_number) and is_list(opts) do
    do_shard(query, nbr_shards, shard_number, opts)
  end

  ## Private functions

  defp do_shard(query, nbr_shards, shard_number, opts)
       when is_map(query) and is_integer(nbr_shards) and nbr_shards > 0 and is_list(opts) do
    field_name = Keyword.get(opts, :field_name, "shard_number")
    doc_field = Keyword.get(opts, :doc_field, "_id")
    alphabet = Keyword.get(opts, :alphabet, :safe_base64)
    return_field = Keyword.get(opts, :return_field, false)

    query
    |> update_runtime_mappings(field_name, nbr_shards, doc_field, alphabet)
    |> maybe_return_field(return_field, field_name)
    |> maybe_filter_field(nbr_shards, shard_number, field_name)
  end

  defp maybe_filter_field(query, nbr_shards, shard_number, field_name)
       when is_integer(shard_number) do
    unless shard_number > 0 and shard_number < nbr_shards do
      raise ArgumentError,
            "invalid shard number: #{shard_number}, expected to be in 1..#{nbr_shards - 1}"
    end

    default = %{term: %{field_name => shard_number}}

    Map.update(query, :query, default, fn
      nil ->
        default

      %{match_all: %{}} ->
        default

      %{bool: %{filter: filter_clause} = bool_clause} when map_size(bool_clause) == 1 ->
        %{bool: %{filter: [default | List.wrap(filter_clause)]}}

      %{bool: %{must: must_clause} = bool_clause} when map_size(bool_clause) == 1 ->
        %{bool: %{must: [default | List.wrap(must_clause)]}}

      query when is_map(query) ->
        %{bool: %{must: [query, default]}}
    end)
  end

  defp maybe_filter_field(query, _nbr_shards, _shard_number, _field_name) do
    query
  end

  defp update_runtime_mappings(query, field_name, nbr_shards, doc_field, alphabet) do
    script_source = runtime_mapping(nbr_shards, doc_field, alphabet)
    shard_number = %{type: "long", script: %{source: script_source}}
    default_runtime_mappings = %{field_name => shard_number}

    Map.update(query, :runtime_mappings, default_runtime_mappings, fn
      nil ->
        default_runtime_mappings

      mappings ->
        Map.put(mappings, field_name, shard_number)
    end)
  end

  defp maybe_return_field(query, true, field_name) do
    default = [field_name]

    Map.update(query, :fields, default, fn
      nil ->
        default

      fields when is_list(fields) ->
        [field_name | fields]
    end)
  end

  defp maybe_return_field(query, _return_field, _field_name) do
    query
  end

  defp runtime_mapping(nbr_shards, field, alphabet)
       when is_integer(nbr_shards) and nbr_shards > 1 and is_binary(field) and
              byte_size(field) > 0 do
    {alphabet_length, formatted_alphabet} = alphabet(alphabet)

    """
    LinkedHashMap alphabet = new LinkedHashMap([#{formatted_alphabet}]);
    BigInteger alphabet_length = BigInteger.valueOf(#{alphabet_length});
    String document_id = doc['#{field}'].value;
    int document_length = document_id.length();
    BigInteger result = BigInteger.valueOf(0);

    for (int i = 0; i < document_length; i++) {
      int step = document_length - i - 1;
      BigInteger bit_value = alphabet_length.pow(step);
      char character = document_id.charAt(i);
      BigInteger char_value = alphabet.get(character);

      result = result.add(bit_value.multiply(char_value));
    }

    BigInteger sharding_size = BigInteger.valueOf(#{nbr_shards});
    BigInteger shard_part = result.mod(sharding_size);
    long modulo = shard_part.longValueExact();

    emit(modulo);
    """
  end

  defp alphabet(alphabet) do
    characters = Map.fetch!(@alphabets, alphabet)

    {length(characters), format_alphabet(characters)}
  end

  defp format_alphabet(alphabet) do
    alphabet
    |> Enum.with_index()
    |> Enum.map_join(", ", fn {char, value} ->
      ~s<(char)"#{char}" : new BigInteger("#{value}")>
    end)
  end
end
