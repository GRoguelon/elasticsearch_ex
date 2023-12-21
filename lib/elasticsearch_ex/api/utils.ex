defmodule ElasticsearchEx.Api.Utils do
  @moduledoc """
  Provides some helpers to make the HTTP calls easier by extracting and manipulating options.
  """

  ## Module attributes

  @type index :: atom() | binary()

  @type id :: binary()

  @type opts :: keyword()

  ## Public functions

  @doc """
  Takes all the items of the list and merge to a valid URL.

  Removes the `nil` values and add a leading `/`.
  """
  @spec merge_path_items([nil | atom() | binary()]) :: binary()
  def merge_path_items(paths) when is_list(paths) and paths != [] do
    ["" | paths] |> Enum.reject(&is_nil/1) |> Enum.map_join("/", &to_string/1)
  end

  @doc """
  Extracts from the `opts`, the key `index` and `id`.

  Raises an exception if the `index` key is missing.
  """
  @spec extract_required_index_and_optional_id!(opts()) :: {index(), nil | id(), opts()}
  def extract_required_index_and_optional_id!(opts) do
    {index, opts} = Keyword.pop!(opts, :index)
    {id, opts} = Keyword.pop(opts, :id)

    {index, id, opts}
  end

  @doc """
  Extracts from the `opts`, the key `index` and `id`.

  Raises an exception if the `index` or the `id` keys are missing.
  """
  @spec extract_required_index_and_required_id!(opts()) :: {index(), id(), opts()}
  def extract_required_index_and_required_id!(opts) do
    {index, opts} = Keyword.pop!(opts, :index)
    {id, opts} = Keyword.pop!(opts, :id)

    {index, id, opts}
  end

  @doc """
  Extracts from the `opts` the index and the other options.
  """
  @spec extract_optional_index(opts(), nil | index()) :: {nil | index(), opts()}
  def extract_optional_index(opts, default_index \\ nil) when is_list(opts) do
    Keyword.pop(opts, :index, default_index)
  end

  @doc """
  Extracts from the `opts` the index and the other options.

  Raises an exception if the option `index` is missing.
  """
  @spec extract_required_index!(opts()) :: {index(), opts()}
  def extract_required_index!(opts) when is_list(opts) do
    Keyword.pop!(opts, :index)
  end
end
