defmodule ElasticsearchEx.MapExt do
  @moduledoc """
  Defines a helper function to convert the keys of a map from string into atoms.

  It support nested data structure.
  """

  ## Public functions

  @spec atomize_keys(map()) :: map()
  def atomize_keys(map) when is_map(map) and not is_struct(map) do
    Map.new(map, fn
      {key, value} when is_binary(key) ->
        {String.to_atom(key), maybe_atomize_value(value)}

      {key, value} ->
        {key, maybe_atomize_value(value)}
    end)
  end

  ## Private functions

  @spec maybe_atomize_value(any()) :: any()
  def maybe_atomize_value(value) when is_map(value) and not is_struct(value) do
    atomize_keys(value)
  end

  def maybe_atomize_value(values) when is_list(values) do
    Enum.map(values, &maybe_atomize_value/1)
  end

  def maybe_atomize_value(value) do
    value
  end
end
