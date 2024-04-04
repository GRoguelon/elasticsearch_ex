defmodule ElasticsearchEx.Guards do
  @moduledoc false

  ## Public guards

  @doc """
  Checks if the `value` is a valid index name or `nil`.
  """
  @deprecated "use `is_name/1` instead"
  defguard is_index_or_nil(value)
           when is_atom(value) or (is_binary(value) and byte_size(value) > 0)

  @doc """
  Checks if the `value` is a valid index name.
  """
  @deprecated "use `is_name!/1` instead"
  defguard is_index(value)
           when (is_binary(value) and byte_size(value) > 0) or
                  (is_atom(value) and not is_nil(value))

  @doc """
  Checks if the `value` is a valid index/field name.
  """
  defguard is_name(value) when is_atom(value) or (is_binary(value) and byte_size(value) > 0)

  @doc """
  Checks if the `value` is a valid index/field name.
  """
  defguard is_name!(value)
           when (is_binary(value) and byte_size(value) > 0) or
                  (is_atom(value) and not is_nil(value))

  @doc """
  Checks if the `value` is a valid document ID.
  """
  defguard is_identifier(value) when is_binary(value) and byte_size(value) > 0

  @doc """
  Checks if the `value` is an enumerable (`List` or `Stream`).
  """
  defguard is_enum(value) when is_list(value) or is_struct(value, Stream)
end
