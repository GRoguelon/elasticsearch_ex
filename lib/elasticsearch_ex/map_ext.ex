defmodule ElasticsearchEx.MapExt do
  @moduledoc false

  ## Public functions

  @spec atomize_keys(map()) :: map()
  def atomize_keys(map), do: map_keys(map, &String.to_atom/1)

  @spec map_keys(map(), nil | (binary() -> any())) :: map()
  def map_keys(map, key_mapper \\ nil)

  def map_keys(value, nil), do: value

  def map_keys(list, key_mapper) when is_list(list) do
    Enum.map(list, &map_keys(&1, key_mapper))
  end

  def map_keys(%{} = map, key_mapper) when is_function(key_mapper, 1) do
    Map.new(map, fn
      {key, value} when is_binary(key) ->
        {key_mapper.(key), maybe_map(value, key_mapper)}

      {key, value} ->
        {key, maybe_map(value, key_mapper)}
    end)
  end

  ## Private functions

  @spec maybe_map(any(), (binary() -> any())) :: any()
  def maybe_map(value, key_mapper) when is_map(value) and not is_struct(value) do
    map_keys(value, key_mapper)
  end

  def maybe_map(values, key_mapper) when is_list(values) do
    Enum.map(values, &maybe_map(&1, key_mapper))
  end

  def maybe_map(value, _key_mapper) do
    value
  end
end
