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
  Refer to `ElasticsearchEx.Api.Search.search/0` documentation.
  """
  @doc since: "1.5.0"
  @spec search() :: response()
  defdelegate search(), to: ElasticsearchEx.Api.Search

  @doc """
  Refer to `ElasticsearchEx.Api.Search.search/1` documentation.
  """
  @doc since: "1.5.0"
  @spec search(query() | index() | opts()) :: response()
  defdelegate search(query_or_index_or_opts), to: ElasticsearchEx.Api.Search

  @doc """
  Refer to `ElasticsearchEx.Api.Search.search/2` documentation.
  """
  @doc since: "1.5.0"
  @spec search(query() | index(), index() | opts()) :: response()
  defdelegate search(query_or_index, index_or_opts), to: ElasticsearchEx.Api.Search

  @doc """
  Refer to `ElasticsearchEx.Api.Search.search/3` documentation.
  """
  @doc since: "1.0.0"
  @spec search(query(), index(), keyword()) :: response()
  defdelegate search(query, index, opts), to: ElasticsearchEx.Api.Search

  @doc """
  Refer to `ElasticsearchEx.Api.Document.index/4` documentation.
  """
  @doc since: "1.0.0"
  @spec index(source(), index(), nil | document_id(), keyword()) :: response()
  defdelegate index(source, index, document_id \\ nil, opts \\ []),
    to: ElasticsearchEx.Api.Document

  @doc """
  Refer to `ElasticsearchEx.Api.Search.search/2` documentation.
  """
  @doc since: "1.3.0"
  @spec stream(query(), nil | index(), keyword()) :: Enumerable.t()
  defdelegate stream(query, index \\ nil, opts \\ []), to: ElasticsearchEx.Streamer
end
