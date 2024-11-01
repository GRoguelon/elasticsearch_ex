defmodule ElasticsearchEx.Utils do
  @moduledoc false

  import ElasticsearchEx.Guards,
    only: [
      is_enum: 1
    ]

  ## Typespecs

  @type path_indices :: nil | atom() | binary() | [atom() | binary()]

  ## Public functions

  @spec generate_index_values_for_path(path_indices()) :: nil | binary()
  defp generate_index_values_for_path(value) do
    cond do
      is_nil(value) ->
        nil

      is_list(value) ->
        Enum.map_join(value, ",", &to_string/1)

      is_atom(value) ->
        Atom.to_string(value)

      is_binary(value) ->
        value
    end
  end

  @spec compose_indexed_path_prefix(binary(), path_indices()) :: binary()
  def compose_indexed_path_prefix(prefix, value) do
    indices = generate_index_values_for_path(value)

    path =
      if is_binary(indices) do
        prefix <> "/" <> indices
      else
        prefix
      end

    maybe_leading_slash(path)
  end

  @spec compose_indexed_path_suffix(path_indices(), binary()) :: binary()
  def compose_indexed_path_suffix(value, suffix) do
    indices = generate_index_values_for_path(value)

    path =
      if is_binary(indices) do
        indices <> "/" <> suffix
      else
        suffix
      end

    maybe_leading_slash(path)
  end

  @spec compose_indexed_path_suffix(path_indices(), binary(), binary()) :: binary()
  def compose_indexed_path_suffix(path_indices, suffix, identifier) do
    compose_indexed_path_suffix(path_indices, suffix) <> "/" <> identifier
  end

  defp maybe_leading_slash(<<"/", _::binary>> = path) do
    path
  end

  defp maybe_leading_slash(path) do
    "/" <> path
  end

  @spec append_path_to_uri(URI.t(), nil | atom() | binary() | list()) :: URI.t()
  def append_path_to_uri(uri, [indices | parts]) when is_list(indices) do
    formatted_indices = Enum.map_join(indices, ",", &to_string/1)

    append_path_to_uri(uri, [formatted_indices | parts])
  end

  def append_path_to_uri(uri, path) when is_list(path) do
    Enum.reduce(path, uri, fn part, acc -> append_path_to_uri(acc, part) end)
  end

  def append_path_to_uri(uri, nil) do
    uri
  end

  def append_path_to_uri(uri, path) when is_atom(path) do
    path = Atom.to_string(path)

    append_path_to_uri(uri, path)
  end

  def append_path_to_uri(uri, "/" <> _ = path) do
    uri_append_path(uri, path)
  end

  def append_path_to_uri(uri, path) when is_binary(path) do
    uri_append_path(uri, "/" <> path)
  end

  @spec generate_path(Enumerable.t()) :: binary()
  def generate_path(segments) when is_enum(segments) and segments != [] do
    ["" | segments] |> Enum.reject(&is_nil/1) |> Enum.join("/")
  end

  if System.version() |> Version.parse!() |> Version.match?("~> 1.15") do
    @spec uri_append_path(URI.t(), binary()) :: URI.t()
    def uri_append_path(%URI{} = uri, path) do
      URI.append_path(uri, path)
    end
  else
    @spec uri_append_path(URI.t(), binary()) :: URI.t()
    def uri_append_path(%URI{}, "//" <> _ = path) do
      raise ArgumentError, ~s|path cannot start with "//", got: #{inspect(path)}|
    end

    def uri_append_path(%URI{path: path} = uri, "/" <> rest = all) do
      cond do
        path == nil ->
          %{uri | path: all}

        path != "" and :binary.last(path) == ?/ ->
          %{uri | path: path <> rest}

        true ->
          %{uri | path: path <> all}
      end
    end

    def uri_append_path(%URI{}, path) when is_binary(path) do
      raise ArgumentError, ~s|path must start with "/", got: #{inspect(path)}|
    end
  end
end
