defmodule ElasticsearchEx do
  @moduledoc """
  Provides some convenient functions.
  """

  @doc """
  Refer to `ElasticsearchEx.Api.Search.Core.search/2` documentation.
  """
  @spec search(
          ElasticsearchEx.Api.Search.Core.search_body(),
          ElasticsearchEx.Api.Search.Core.search_opts()
        ) :: ElasticsearchEx.Client.response()
  defdelegate search(query, opts), to: ElasticsearchEx.Api.Search.Core
end
