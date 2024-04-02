defmodule ElasticsearchEx.Api.Source do
  @moduledoc """
  Provides the APIs for document source operations.
  """

  import ElasticsearchEx.Api.Utils,
    only: [
      extract_required_index_and_required_id!: 1
    ]

  alias ElasticsearchEx.Client

  ## Public functions

  @doc """
  Retrieves the specified JSON document from an index.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-get.html#docs-get-api-query-params)
  for a detailed list of the parameters.

  ### Examples

      iex> ElasticsearchEx.Api.Source.get(index: "my-index-000001", id: "0")
      {:ok,
       %{
         "@timestamp" => "2099-11-15T14:12:12",
         "http" => %{
           "request" => %{"method" => "get"},
           "response" => %{"bytes" => 1_070_000, "status_code" => 200},
           "version" => "1.1"
         },
         "message" => "GET /search HTTP/1.1 200 1070000",
         "source" => %{"ip" => "127.0.0.1"},
         "user" => %{"id" => "kimchy"}
       }}
  """
  @spec get(keyword()) :: ElasticsearchEx.response()
  def get(opts \\ []) when is_list(opts) do
    {index, document_id, opts} = extract_required_index_and_required_id!(opts)

    Client.get("#{index}/_source/#{document_id}", nil, nil, opts)
  end

  @doc """
  Checks if the specified JSON document from an index exists.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-get.html#docs-get-api-query-params)
  for a detailed list of the parameters.

  ### Examples

      iex> ElasticsearchEx.Api.Source.exists?(index: "my-index-000001", id: "0")
      true
  """
  @spec exists?(keyword()) :: boolean()
  def exists?(opts \\ []) when is_list(opts) do
    {index, document_id, opts} = extract_required_index_and_required_id!(opts)

    Client.head("#{index}/_source/#{document_id}", nil, opts) == :ok
  end
end
