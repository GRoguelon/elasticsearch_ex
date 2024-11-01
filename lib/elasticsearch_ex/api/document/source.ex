defmodule ElasticsearchEx.API.Document.Source do
  @moduledoc """
  Provides the APIs for document source operations.
  """

  import ElasticsearchEx.Client, only: [request: 4]

  import ElasticsearchEx.Utils, only: [generate_path_with_suffix: 2]

  import ElasticsearchEx.Guards,
    only: [
      is_identifier: 1,
      is_name!: 1
    ]

  ## Typespecs

  @type document_id :: ElasticsearchEx.document_id()

  @type index :: ElasticsearchEx.index()

  @type opts :: ElasticsearchEx.opts()

  ## Public functions

  @doc """
  Retrieves the specified JSON document from an index.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-get.html#docs-get-api-query-params)
  for a detailed list of the parameters.

  ### Examples

      iex> ElasticsearchEx.API.Document.Source.get("0", "my-index-000001")
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
  @doc since: "1.0.0"
  @spec get(index(), document_id(), keyword()) :: ElasticsearchEx.response()
  def get(index, document_id, opts \\ []) when is_name!(index) and is_identifier(document_id) do
    path = generate_path_with_suffix(index, "/_source/" <> document_id)

    request(:get, path, nil, opts)
  end

  @doc """
  Checks if the specified JSON document from an index exists.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-get.html#docs-get-api-query-params)
  for a detailed list of the parameters.

  ### Examples

      iex> ElasticsearchEx.API.Document.Source.exists?("0", "my-index-000001")
      true
  """
  @doc since: "1.0.0"
  @spec exists?(index(), document_id(), keyword()) :: boolean()
  def exists?(index, document_id, opts \\ []) do
    path = generate_path_with_suffix(index, "/_source/" <> document_id)

    request(:head, path, nil, opts) == {:ok, ""}
  end
end
