defmodule ElasticsearchEx do
  @moduledoc """
  Provides some convenient functions.
  """

  @doc """
  Refer to `ElasticsearchEx.Api.Search.Core.search/2` documentation.
  """
  @spec search(map(), keyword()) :: {:ok, Req.Response.t()} | {:error, Exception.t()}
  defdelegate search(query, opts), to: ElasticsearchEx.Api.Search.Core
end
