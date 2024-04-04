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
end
