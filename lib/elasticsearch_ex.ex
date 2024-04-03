defmodule ElasticsearchEx do
  @moduledoc """
  Provides some convenient functions.
  """

  ## Module attributes

  @type query :: map()

  @type source :: map()

  @type document_id :: binary()

  @type index :: atom() | binary()

  @type opts :: keyword()

  @type response :: {:ok, term()} | {:error, ElasticsearchEx.Error.t()}

  ## Public functions

  @doc """
  Refer to `ElasticsearchEx.Api.Search.search/2` documentation.
  """
  @spec search(query(), index(), keyword()) :: response()
  defdelegate search(query, index \\ nil, opts \\ []), to: ElasticsearchEx.Api.Search

  @doc """
  Refer to `ElasticsearchEx.Api.Document.index/4` documentation.
  """
  @spec index(source(), index(), nil | document_id(), keyword()) :: response()
  defdelegate index(source, index, document_id \\ nil, opts \\ []),
    to: ElasticsearchEx.Api.Document
end
