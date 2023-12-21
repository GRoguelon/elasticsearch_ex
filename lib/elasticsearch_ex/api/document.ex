defmodule ElasticsearchEx.Api.Document do
  @moduledoc """
  Provides the APIs for the single document operations.
  """

  import ElasticsearchEx.Api.Utils,
    only: [
      extract_required_index_and_optional_id!: 1,
      extract_required_index_and_required_id!: 1,
      merge_path_items: 1
    ]

  alias ElasticsearchEx.Client

  ## Public functions

  @doc """
  Adds a JSON document to the specified data stream or index and makes it searchable. If the
  target is an index and the document already exists, the request updates the document and
  increments its version.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-index_.html#docs-index-api-query-params)
  for a detailed list of the parameters.

  ### Request body

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-index_.html#docs-index-api-request-body)
  for a detailed list of the body values.

  ### Examples

  Without a specific document ID:

      iex> ElasticsearchEx.Api.Document.index(
      ...>   %{
      ...>     "@timestamp": "2099-11-15T13:12:00",
      ...>     message: "GET /search HTTP/1.1 200 1070000",
      ...>     user: %{id: "kimchy"}
      ...>   },
      ...>   index: "my-index-000001"
      ...> )
      {:ok,
       %{
         "_id" => "W0tpsmIBdwcYyG50zbta",
         "_index" => "my-index-000001",
         "_primary_term" => 1,
         "_seq_no" => 0,
         "_shards" => %{"failed" => 0, "successful" => 2, "total" => 2},
         "_version" => 1,
         "result" => "created"
       }}

  With a specific document ID:

      iex> ElasticsearchEx.Api.Document.index(
      ...>   %{
      ...>     "@timestamp": "2099-11-15T13:12:00",
      ...>     message: "GET /search HTTP/1.1 200 1070000",
      ...>     user: %{id: "kimchy"}
      ...>   },
      ...>   index: "my-index-000001",
      ...>   id: "W0tpsmIBdwcYyG50zbta"
      ...> )
      {:ok,
       %{
         "_id" => "W0tpsmIBdwcYyG50zbta",
         "_index" => "my-index-000001",
         "_primary_term" => 1,
         "_seq_no" => 0,
         "_shards" => %{"failed" => 0, "successful" => 2, "total" => 2},
         "_version" => 1,
         "result" => "created"
       }}
  """
  @spec index(map(), keyword()) :: ElasticsearchEx.response()
  def index(document, opts \\ []) when is_map(document) and is_list(opts) do
    {index, document_id, opts} = extract_required_index_and_optional_id!(opts)
    path = merge_path_items([index, "_doc", document_id])

    Client.post(path, nil, document, opts)
  end

  @doc """
  Adds a JSON document to the specified data stream or index and makes it searchable.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-index_.html#docs-index-api-query-params)
  for a detailed list of the parameters.

  ### Request body

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-index_.html#docs-index-api-request-body)
  for a detailed list of the body values.

  ### Examples

      iex> ElasticsearchEx.Api.Document.create(
      ...>   %{
      ...>     "@timestamp": "2099-11-15T13:12:00",
      ...>     message: "GET /search HTTP/1.1 200 1070000",
      ...>     user: %{id: "kimchy"}
      ...>   },
      ...>   index: "my-index-000001",
      ...>   id: "W0tpsmIBdwcYyG50zbta"
      ...> )
      {:ok,
       %{
         "_id" => "W0tpsmIBdwcYyG50zbta",
         "_index" => "my-index-000001",
         "_primary_term" => 1,
         "_seq_no" => 0,
         "_shards" => %{"failed" => 0, "successful" => 2, "total" => 2},
         "_version" => 1,
         "result" => "created"
       }}
  """
  @spec create(map(), keyword()) :: ElasticsearchEx.response()
  def create(document, opts \\ []) when is_map(document) and is_list(opts) do
    {index, document_id, opts} = extract_required_index_and_required_id!(opts)

    Client.post("#{index}/_doc/#{document_id}", nil, document, opts)
  end

  @doc """
  Retrieves the specified JSON document from an index.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-get.html#docs-get-api-query-params)
  for a detailed list of the parameters.

  ### Examples

      iex> ElasticsearchEx.Api.Document.get_document(index: "my-index-000001", id: "0")
      {:ok,
       %{
         "_id" => "0",
         "_index" => "my-index-000001",
         "_primary_term" => 1,
         "_seq_no" => 0,
         "_source" => %{
           "@timestamp" => "2099-11-15T14:12:12",
           "http" => %{
             "request" => %{"method" => "get"},
             "response" => %{"bytes" => 1070000, "status_code" => 200},
             "version" => "1.1"
           },
           "message" => "GET /search HTTP/1.1 200 1070000",
           "source" => %{"ip" => "127.0.0.1"},
           "user" => %{"id" => "kimchy"}
         },
         "_version" => 1,
         "found" => true
       }}
  """
  @spec get_document(keyword()) :: ElasticsearchEx.response()
  def get_document(opts \\ []) when is_list(opts) do
    {index, document_id, opts} = extract_required_index_and_required_id!(opts)

    Client.get("#{index}/_doc/#{document_id}", nil, nil, opts)
  end

  @doc """
  Retrieves the specified JSON source from an index.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-get.html#docs-get-api-query-params)
  for a detailed list of the parameters.

  ### Examples

      iex> ElasticsearchEx.Api.Document.get_source(index: "my-index-000001", id: "0")
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
  @spec get_source(keyword()) :: ElasticsearchEx.response()
  def get_source(opts \\ []) when is_list(opts) do
    {index, document_id, opts} = extract_required_index_and_required_id!(opts)

    Client.get("#{index}/_source/#{document_id}", nil, nil, opts)
  end

  @doc """
  Checks if the specified JSON document from an index exists.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-get.html#docs-get-api-query-params)
  for a detailed list of the parameters.

  ### Examples

      iex> ElasticsearchEx.Api.Document.document_exists?(index: "my-index-000001", id: "0")
      true
  """
  @spec document_exists?(keyword()) :: boolean()
  def document_exists?(opts \\ []) when is_list(opts) do
    {index, document_id, opts} = extract_required_index_and_required_id!(opts)

    Client.head("#{index}/_doc/#{document_id}", nil, opts) == :ok
  end

  @doc """
  Checks if the specified JSON source from an index exists.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-get.html#docs-get-api-query-params)
  for a detailed list of the parameters.

  ### Examples

      iex> ElasticsearchEx.Api.Document.source_exists?(index: "my-index-000001", id: "0")
      true
  """
  @spec source_exists?(keyword()) :: boolean()
  def source_exists?(opts \\ []) when is_list(opts) do
    {index, document_id, opts} = extract_required_index_and_required_id!(opts)

    Client.head("#{index}/_source/#{document_id}", nil, opts) == :ok
  end

  @doc """
  Removes a JSON document from the specified index.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-delete.html#docs-delete-api-query-params)
  for a detailed list of the parameters.

  ### Examples

      iex> ElasticsearchEx.Api.Document.delete(index: "my-index-000001", id: "0")
      {:ok,
       %{
         "_id" => "0",
         "_index" => "my-index-000001",
         "_primary_term" => 3,
         "_seq_no" => 6,
         "_shards" => %{"failed" => 0, "successful" => 1, "total" => 2},
         "_version" => 2,
         "result" => "deleted"
       }}

      iex> ElasticsearchEx.Api.Document.delete(index: "my-index-000001", id: "1")
      {:error,
       %ElasticsearchEx.Error{
         reason: "Document with ID: `1` not found",
         root_cause: nil,
         status: 404,
         type: "not_found",
         ...
       }}
  """
  @spec delete(keyword()) :: ElasticsearchEx.response()
  def delete(opts \\ []) do
    {index, document_id, opts} = extract_required_index_and_required_id!(opts)

    Client.delete("#{index}/_doc/#{document_id}", nil, nil, opts)
  end

  @doc """
  Updates a document using the specified script.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-update.html#docs-update-api-query-params)
  for a detailed list of the parameters.

  ### Request body

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-update.html#update-api-example)
  for a detailed list of the body values.

  ### Examples

      iex> ElasticsearchEx.Api.Document.update(
      ...>   %{
      ...>     script: %{
      ...>       source: "ctx._source.message = params.message",
      ...>       lang: "painless",
      ...>       params: %{message: "Bye World"}
      ...>     }
      ...>   },
      ...>   index: "my-index-000001",
      ...>   id: "0"
      ...> )
      {:ok,
       %{
         "_id" => "0",
         "_index" => "my-index-000001",
         "_primary_term" => 1,
         "_seq_no" => 1,
         "_version" => 2,
         "_shards" => %{"failed" => 0, "successful" => 1, "total" => 1},
         "result" => "updated"
       }}
  """
  @spec update(map(), keyword()) :: ElasticsearchEx.response()
  def update(document, opts \\ []) do
    {index, document_id, opts} = extract_required_index_and_required_id!(opts)

    Client.post("#{index}/_update/#{document_id}", nil, document, opts)
  end
end
