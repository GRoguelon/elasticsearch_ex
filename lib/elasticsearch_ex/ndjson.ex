defmodule ElasticsearchEx.Ndjson do
  @moduledoc """
  Provides some helpers to manipulate NDJSON (Newline Delimited JSON).
  """

  ## Module attributes

  @delimiter "\n"

  ## Public functions

  @doc """
  Encodes a list of values into a valid NDJSON.

  Raises an exception if the JSON encoding fails.

  ### Examples

      iex> ElasticsearchEx.Ndjson.encode!([%{a: :b}, %{c: :d}])
      "{\\"a\\":\\"b\\"}\\n{\\"c\\":\\"d\\"}\\n"
  """
  @spec encode!(Enumerable.t()) :: Enumerable.t()
  def encode!(list) when is_list(list) do
    Enum.map_join(list, @delimiter, &Jason.encode!/1) <> @delimiter
  end

  @doc """
  Decodes a binary into a list of `term`.

  Raises an exception if the JSON decoding fails.

  ### Examples

      iex> ElasticsearchEx.Ndjson.decode!("{\\"a\\":\\"b\\"}\\n{\\"c\\":\\"d\\"}\\n")
      [%{a: :b}, %{c: :d}]
  """
  def decode!(string) when is_binary(string) do
    string
    |> String.trim_trailing(@delimiter)
    |> String.split(@delimiter)
    |> Enum.map(&Jason.decode!/1)
  end
end
