defmodule ElasticsearchEx.Utils do
  @moduledoc false

  import ElasticsearchEx.Guards, only: [is_enum: 1, is_identifier: 1]

  ## Public functions

  @spec format_path(nil | Enumerable.t() | binary(), atom() | binary()) :: binary()
  def format_path(nil, operation) when is_identifier(operation) do
    "/#{operation}"
  end

  def format_path(prefix, operation) when is_enum(prefix) and is_identifier(operation) do
    prefix |> Enum.join(",") |> format_path(operation)
  end

  def format_path(prefix, operation) when is_identifier(prefix) and is_identifier(operation) do
    "/#{prefix}/#{operation}"
  end

  @spec format_path(nil | Enumerable.t() | binary(), atom() | binary(), atom() | binary()) ::
          binary()
  def format_path(nil, operation, suffix)
      when is_identifier(operation) and is_identifier(suffix) do
    "/#{operation}/#{suffix}"
  end

  def format_path(prefix, operation, suffix)
      when is_enum(prefix) and is_identifier(operation) and is_identifier(suffix) do
    prefix |> Enum.join(",") |> format_path(operation, suffix)
  end

  def format_path(prefix, operation, suffix)
      when is_identifier(prefix) and is_identifier(operation) and is_identifier(suffix) do
    "/#{prefix}/#{operation}/#{suffix}"
  end
end
