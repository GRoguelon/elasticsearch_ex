defmodule ElasticsearchEx.Utils do
  @moduledoc false

  import ElasticsearchEx.Guards,
    only: [
      is_enum: 1,
      is_identifier: 1,
      is_name: 1,
      is_name!: 1
    ]

  ## Public functions

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

  @deprecated "use `generate_path/1` instead"
  @spec format_path(Enumerable.t() | nil | atom() | binary(), atom() | binary()) :: binary()
  def format_path(nil, operation) when is_name!(operation) do
    "/#{operation}"
  end

  def format_path(prefix, operation) when is_enum(prefix) do
    prefix |> Enum.join(",") |> format_path(operation)
  end

  def format_path(prefix, operation) when is_name(prefix) and is_name!(operation) do
    "/#{prefix}/#{operation}"
  end

  @deprecated "use `generate_path/1` instead"
  @spec format_path(nil | Enumerable.t() | binary(), atom() | binary(), atom() | binary()) ::
          binary()
  def format_path(nil, operation, suffix) when is_name!(operation) and is_identifier(suffix) do
    "/#{operation}/#{suffix}"
  end

  def format_path(prefix, operation, suffix) when is_enum(prefix) do
    prefix |> Enum.join(",") |> format_path(operation, suffix)
  end

  def format_path(prefix, operation, suffix)
      when is_name(prefix) and is_name!(operation) and is_identifier(suffix) do
    "/#{prefix}/#{operation}/#{suffix}"
  end

  ## Private functions

  if System.version() |> Version.parse!() |> Version.match?("~> 1.15") do
    @spec uri_append_path(URI.t(), binary()) :: URI.t()
    defp uri_append_path(%URI{} = uri, path) do
      URI.append_path(uri, path)
    end
  else
    @spec uri_append_path(URI.t(), binary()) :: URI.t()
    defp uri_append_path(%URI{}, "//" <> _ = path) do
      raise ArgumentError, ~s|path cannot start with "//", got: #{inspect(path)}|
    end

    defp uri_append_path(%URI{path: path} = uri, "/" <> rest = all) do
      cond do
        path == nil ->
          %{uri | path: all}

        path != "" and :binary.last(path) == ?/ ->
          %{uri | path: path <> rest}

        true ->
          %{uri | path: path <> all}
      end
    end

    defp uri_append_path(%URI{}, path) when is_binary(path) do
      raise ArgumentError, ~s|path must start with "/", got: #{inspect(path)}|
    end
  end
end
