defmodule ElasticsearchEx.Api.Utils do
  @moduledoc false

  ## Public functions

  @doc """
  Extracts from the `opts` the index, the URL parameters and the adapter options.
  """
  @spec extract_index(keyword(), nil | atom() | binary()) :: {nil | atom() | binary(), keyword()}
  def extract_index(opts, default_index \\ nil) when is_list(opts) do
    Keyword.pop(opts, :index, default_index)
  end

  @doc """
  Ensures that the suffix is added to the path.

  If the path is `nil`, the suffix is returned.
  """
  @spec merge_path_suffix(nil | atom() | binary(), binary()) :: binary()
  def merge_path_suffix(nil, suffix) do
    "/#{suffix}"
  end

  def merge_path_suffix(path, suffix) do
    "/#{path}/#{suffix}"
  end
end
