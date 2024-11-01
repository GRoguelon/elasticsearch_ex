defmodule ElasticsearchEx.Utils do
  @moduledoc false

  ## Typespecs

  @type single_target :: atom() | binary()

  @type multi_target :: single_target() | [single_target()]

  @type path_indices :: nil | atom() | binary() | [atom() | binary()]

  ## Public functions

  @spec generate_path_with_prefix(nil | multi_target(), binary()) :: binary()
  def generate_path_with_prefix(target, prefix) do
    leading_slash_prefix = maybe_leading_slash(prefix)

    if target_as_str = target_to_string(target) do
      leading_slash_prefix <> maybe_leading_slash(target_as_str)
    else
      leading_slash_prefix
    end
  end

  @spec generate_path_with_suffix(nil | multi_target(), binary()) :: binary()
  def generate_path_with_suffix(target, suffix) do
    leading_slash_suffix = maybe_leading_slash(suffix)

    if target_as_str = target_to_string(target) do
      maybe_leading_slash(target_as_str) <> leading_slash_suffix
    else
      leading_slash_suffix
    end
  end

  @spec generate_path_with_wrapper(nil | multi_target(), binary(), binary()) :: binary()
  def generate_path_with_wrapper(target, prefix, suffix) do
    leading_slash_prefix = maybe_leading_slash(prefix)
    leading_slash_suffix = maybe_leading_slash(suffix)

    if target_as_str = target_to_string(target) do
      leading_slash_prefix <> maybe_leading_slash(target_as_str) <> leading_slash_suffix
    else
      leading_slash_prefix <> leading_slash_suffix
    end
  end

  @spec target_to_string(nil | multi_target()) :: nil | binary()
  defp target_to_string(targets) when is_list(targets) do
    Enum.map_join(targets, ",", &target_to_string/1)
  end

  defp target_to_string(target) when is_nil(target) do
    nil
  end

  defp target_to_string(target) when is_atom(target) do
    Atom.to_string(target)
  end

  defp target_to_string(target) when is_binary(target) do
    target
  end

  @spec maybe_leading_slash(binary()) :: binary()
  def maybe_leading_slash(<<"/", _::binary>> = path), do: path

  def maybe_leading_slash(path), do: "/" <> path

  if System.version() |> Version.parse!() |> Version.match?("~> 1.15") do
    @spec uri_append_path(URI.t(), binary()) :: URI.t()
    defdelegate append_path(uri_or_url, path), to: URI
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
