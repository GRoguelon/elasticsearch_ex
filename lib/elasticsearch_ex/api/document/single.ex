defmodule ElasticsearchEx.Api.Document.Single do
  @moduledoc """
  Provides the APIs for the single document operations.
  """

  import ElasticsearchEx.Api.Utils, only: [extract_index!: 1]

  alias ElasticsearchEx.Client

  ## Public functions

  @typedoc "Represents the source of a document"
  @type source :: map()

  @typedoc "The possible individual options accepted by the `search` function."
  @type index_opt :: {:index, atom() | binary()} | {:id, binary()}

  @typedoc "The possible options accepted by the `search` function."
  @type index_opts :: [index_opt() | {:http_opts, keyword()} | {atom(), any()}]

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

      iex> ElasticsearchEx.Api.Document.Single.index(
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

      iex> ElasticsearchEx.Api.Document.Single.index(
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
  @spec index(source(), index_opts()) :: Client.response()
  def index(document, opts \\ []) when is_map(document) and is_list(opts) do
    {index, opts} = extract_index!(opts)
    {document_id, opts} = Keyword.pop(opts, :id)
    path = if(is_nil(document_id), do: "#{index}/_doc", else: "#{index}/_doc/#{document_id}")

    Client.post(path, nil, document, opts)
  end

  @typedoc "The possible individual options accepted by the `search` function."
  @type create_opt :: {:index, atom() | binary()} | {:id, binary()}

  @typedoc "The possible options accepted by the `search` function."
  @type create_opts :: [create_opt() | {:http_opts, keyword()} | {atom(), any()}]

  @doc """
  Adds a JSON document to the specified data stream or index and makes it searchable.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-index_.html#docs-index-api-query-params)
  for a detailed list of the parameters.

  ### Request body

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-index_.html#docs-index-api-request-body)
  for a detailed list of the body values.

  ### Examples

      iex> ElasticsearchEx.Api.Document.Single.create(
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
  @spec create(source(), create_opts()) :: Client.response()
  def create(document, opts \\ []) when is_map(document) and is_list(opts) do
    {index, opts} = extract_index!(opts)
    {document_id, opts} = Keyword.pop!(opts, :id)

    Client.post("#{index}/_doc/#{document_id}", nil, document, opts)
  end

  @typedoc "The possible individual options accepted by the `search` function."
  @type get_document_opt :: {:index, atom() | binary()} | {:id, binary()}

  @typedoc "The possible options accepted by the `search` function."
  @type get_document_opts :: [get_document_opt() | {:http_opts, keyword()} | {atom(), any()}]

  @doc """
  Retrieves the specified JSON document from an index.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-get.html#docs-get-api-query-params)
  for a detailed list of the parameters.

  ### Examples

      iex> ElasticsearchEx.Api.Document.Single.get_document(index: "my-index-000001", id: "0")
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
  @spec get_document(get_document_opts()) :: Client.response()
  def get_document(opts \\ []) when is_list(opts) do
    {index, opts} = extract_index!(opts)
    {document_id, opts} = Keyword.pop!(opts, :id)

    Client.get("#{index}/_doc/#{document_id}", nil, nil, opts)
  end

  @typedoc "The possible individual options accepted by the `search` function."
  @type get_source_opt :: {:index, atom() | binary()} | {:id, binary()}

  @typedoc "The possible options accepted by the `search` function."
  @type get_source_opts :: [get_source_opt() | {:http_opts, keyword()} | {atom(), any()}]

  @doc """
  Retrieves the specified JSON source from an index.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-get.html#docs-get-api-query-params)
  for a detailed list of the parameters.

  ### Examples

      iex> ElasticsearchEx.Api.Document.Single.get_source(index: "my-index-000001", id: "0")
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
  @spec get_source(get_source_opts()) :: Client.response()
  def get_source(opts \\ []) when is_list(opts) do
    {index, opts} = extract_index!(opts)
    {document_id, opts} = Keyword.pop!(opts, :id)

    Client.get("#{index}/_source/#{document_id}", nil, nil, opts)
  end

  @typedoc "The possible individual options accepted by the `search` function."
  @type document_exists_opt :: {:index, atom() | binary()} | {:id, binary()}

  @typedoc "The possible options accepted by the `search` function."
  @type document_exists_opts :: [
          document_exists_opt() | {:http_opts, keyword()} | {atom(), any()}
        ]

  @doc """
  Checks if the specified JSON document from an index exists.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-get.html#docs-get-api-query-params)
  for a detailed list of the parameters.

  ### Examples

      iex> ElasticsearchEx.Api.Document.Single.document_exists?(index: "my-index-000001", id: "0")
      true
  """
  @spec document_exists?(document_exists_opts()) :: boolean()
  def document_exists?(opts \\ []) when is_list(opts) do
    {index, opts} = extract_index!(opts)
    {document_id, opts} = Keyword.pop!(opts, :id)

    Client.head("#{index}/_doc/#{document_id}", nil, opts) == :ok
  end

  @typedoc "The possible individual options accepted by the `search` function."
  @type source_exists_opt :: {:index, atom() | binary()} | {:id, binary()}

  @typedoc "The possible options accepted by the `search` function."
  @type source_exists_opts :: [source_exists_opt() | {:http_opts, keyword()} | {atom(), any()}]

  @doc """
  Checks if the specified JSON source from an index exists.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-get.html#docs-get-api-query-params)
  for a detailed list of the parameters.

  ### Examples

      iex> ElasticsearchEx.Api.Document.Single.source_exists?(index: "my-index-000001", id: "0")
      true
  """
  @spec source_exists?(source_exists_opts()) :: boolean()
  def source_exists?(opts \\ []) when is_list(opts) do
    {index, opts} = extract_index!(opts)
    {document_id, opts} = Keyword.pop!(opts, :id)

    Client.head("#{index}/_source/#{document_id}", nil, opts) == :ok
  end

  @typedoc "The possible individual options accepted by the `search` function."
  @type delete_opt :: {:index, atom() | binary()} | {:id, binary()}

  @typedoc "The possible options accepted by the `search` function."
  @type delete_opts :: [delete_opt() | {:http_opts, keyword()} | {atom(), any()}]

  @doc """
  Removes a JSON document from the specified index.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-delete.html#docs-delete-api-query-params)
  for a detailed list of the parameters.

  ### Examples

      iex> ElasticsearchEx.Api.Document.Single.delete(index: "my-index-000001", id: "0")
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

      iex> ElasticsearchEx.Api.Document.Single.delete(index: "my-index-000001", id: "1")
      {:error,
       %ElasticsearchEx.Error{
         reason: "Document with ID: `1` not found",
         root_cause: nil,
         status: 404,
         type: "not_found",
         ...
       }}
  """
  @spec delete(delete_opts()) :: Client.response()
  def delete(opts \\ []) do
    {index, opts} = extract_index!(opts)
    {document_id, opts} = Keyword.pop!(opts, :id)

    Client.delete("#{index}/_doc/#{document_id}", nil, nil, opts)
  end

  @typedoc "It describes the query sent to update the document."
  @type update_query :: map()

  @typedoc "The possible individual options accepted by the `search` function."
  @type update_opt :: {:index, atom() | binary()} | {:id, binary()}

  @typedoc "The possible options accepted by the `search` function."
  @type update_opts :: [update_opt() | {:http_opts, keyword()} | {atom(), any()}]

  @doc """
  Updates a document using the specified script.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-update.html#docs-update-api-query-params)
  for a detailed list of the parameters.

  ### Request body

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-update.html#update-api-example)
  for a detailed list of the body values.
  """
  @spec update(update_query(), delete_opts()) :: Client.response()
  def update(document, opts \\ []) do
    {index, opts} = extract_index!(opts)
    {document_id, opts} = Keyword.pop!(opts, :id)

    Client.post("#{index}/_doc/#{document_id}", nil, document, opts)
  end
end
