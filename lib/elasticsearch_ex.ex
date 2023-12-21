defmodule ElasticsearchEx do
  @moduledoc """
  Provides some convenient functions.
  """

  ## Module attributes

  @type response :: {:ok, term()} | {:error, ElasticsearchEx.Error.t()}

  ## Public functions

  @doc """
  Refer to `ElasticsearchEx.Api.Search.search/2` documentation.
  """
  @spec search(map(), keyword()) :: response()
  defdelegate search(query, opts \\ []), to: ElasticsearchEx.Api.Search

  @doc """
  Refer to `ElasticsearchEx.Api.Search.search/2` documentation.
  """
  @spec index(map(), keyword()) :: response()
  defdelegate index(document, opts \\ []), to: ElasticsearchEx.Api.Document
end
