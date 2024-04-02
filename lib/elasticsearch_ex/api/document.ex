defmodule ElasticsearchEx.Api.Document do
  @moduledoc """
  Provides the APIs for the single document operations.
  """

  import ElasticsearchEx.Api.Utils,
    only: [
      extract_required_index_and_optional_id!: 1,
      extract_required_index_and_required_id!: 1,
      extract_optional_index: 1,
      merge_path_items: 1
    ]

  require Logger

  alias ElasticsearchEx.Client

  ## Deprecated functions

  # TODO: Remove with v1.0.0
  @doc false
  @deprecated "Use ElasticsearchEx.Api.Document.get/1 instead"
  def get_document(opts \\ []) when is_list(opts) do
    get(opts)
  end

  # TODO: Remove with v1.0.0
  @doc false
  @deprecated "Use ElasticsearchEx.Api.Document.Source.get/1 instead"
  def get_source(opts \\ []) when is_list(opts) do
    ElasticsearchEx.Api.Document.Source.get(opts)
  end

  # TODO: Remove with v1.0.0
  @doc false
  @deprecated "Use ElasticsearchEx.Api.Document.exists?/1 instead"
  def document_exists?(opts \\ []) when is_list(opts) do
    exists?(opts)
  end

  # TODO: Remove with v1.0.0
  @doc false
  @deprecated "Use ElasticsearchEx.Api.Document.Source.exists?/1 instead"
  def source_exists?(opts \\ []) when is_list(opts) do
    ElasticsearchEx.Api.Document.Source.exists?(opts)
  end

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
    path = merge_path_items([index, :_doc, document_id])

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
    path = merge_path_items([index, :_doc, document_id])

    Client.post(path, nil, document, opts)
  end

  @doc """
  Retrieves the specified JSON document from an index.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-get.html#docs-get-api-query-params)
  for a detailed list of the parameters.

  ### Examples

      iex> ElasticsearchEx.Api.Document.get(index: "my-index-000001", id: "0")
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
  @spec get(keyword()) :: ElasticsearchEx.response()
  def get(opts \\ []) when is_list(opts) do
    {index, document_id, opts} = extract_required_index_and_required_id!(opts)
    path = merge_path_items([index, :_doc, document_id])

    Client.get(path, nil, nil, opts)
  end

  @doc """
  Retrieves multiple JSON documents by ID.

  **Note:** The `ids` and `docs` options are mutually exclusive and both accept a `List` or a `Stream`.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-multi-get.html#docs-multi-get-api-query-params)
  for a detailed list of the parameters.

  ### Examples

  Query with only IDs (the option `index` is required):

      iex> ElasticsearchEx.Api.Document.multi_get(
      ...>   ids: ["ArSqnI4BpDBWjw9UsTk-", "BrS8nI4BpDBWjw9UUTk5"],
      ...>   index: "my-index-000001",
      ...>   _source: false
      ...> )
      {:ok,
       %{
         "docs" => [
           %{
             "_id" => "ArSqnI4BpDBWjw9UsTk-",
             "_index" => "my-index-000001",
             "_primary_term" => 2,
             "_seq_no" => 0,
             "_version" => 1,
             "found" => true
           },
           %{
             "_id" => "BrS8nI4BpDBWjw9UUTk5",
             "_index" => "my-index-000001",
             "_primary_term" => 2,
             "_seq_no" => 1,
             "_version" => 1,
             "found" => true
           }
         ]
       }}

  Query with a `List` of `Tuple`:

      iex> ElasticsearchEx.Api.Document.multi_get(
      ...>   docs: [
      ...>     {"my-index-000001", "ArSqnI4BpDBWjw9UsTk-"},
      ...>     {"my-index-000001", "BrS8nI4BpDBWjw9UUTk5"}
      ...>   ],
      ...>   _source: false
      ...> )
      {:ok,
       %{
         "docs" => [
           %{
             "_id" => "ArSqnI4BpDBWjw9UsTk-",
             "_index" => "my-index-000001",
             "_primary_term" => 2,
             "_seq_no" => 0,
             "_version" => 1,
             "found" => true
           },
           %{
             "_id" => "BrS8nI4BpDBWjw9UUTk5",
             "_index" => "my-index-000001",
             "_primary_term" => 2,
             "_seq_no" => 1,
             "_version" => 1,
             "found" => true
           }
         ]
       }}

  Query with a `List` of `Map`, the following keys are supported: `:index`, `:_index`, `:id`,
  `:_id`, `:source`, `:_source`, `:stored_fields`, `:_stored_fields` and `:routing`:

      iex> ElasticsearchEx.Api.Document.multi_get(
      ...>   docs: [
      ...>     %{index: "my-index-000001", id: "ArSqnI4BpDBWjw9UsTk-"},
      ...>     %{index: "my-index-000001", id: "BrS8nI4BpDBWjw9UUTk5"}
      ...>   ],
      ...>   _source: false
      ...> )
      {:ok,
       %{
         "docs" => [
           %{
             "_id" => "ArSqnI4BpDBWjw9UsTk-",
             "_index" => "my-index-000001",
             "_primary_term" => 2,
             "_seq_no" => 0,
             "_version" => 1,
             "found" => true
           },
           %{
             "_id" => "BrS8nI4BpDBWjw9UUTk5",
             "_index" => "my-index-000001",
             "_primary_term" => 2,
             "_seq_no" => 1,
             "_version" => 1,
             "found" => true
           }
         ]
       }}
  """
  @spec multi_get(keyword()) :: ElasticsearchEx.response()
  def multi_get(opts \\ []) when is_list(opts) do
    {index, opts} = extract_optional_index(opts)

    {key, body, opts} =
      cond do
        Keyword.has_key?(opts, :ids) and is_nil(index) ->
          raise ArgumentError, "missing option `index`, must be provided with option `ids`"

        Keyword.has_key?(opts, :ids) ->
          {ids, opts} = Keyword.pop!(opts, :ids)
          formatted_ids = format_multi_get_ids(ids)

          {:ids, formatted_ids, opts}

        Keyword.has_key?(opts, :docs) ->
          {docs, opts} = Keyword.pop!(opts, :docs)
          formatted_docs = format_multi_get_docs(docs, index)

          {:docs, formatted_docs, opts}

        true ->
          raise ArgumentError, "missing option `docs` or `ids`"
      end

    index
    |> generate_mget_path()
    |> do_multi_get(key, body, opts)
  end

  @doc """
  Checks if the specified JSON document from an index exists.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-get.html#docs-get-api-query-params)
  for a detailed list of the parameters.

  ### Examples

      iex> ElasticsearchEx.Api.Document.exists?(index: "my-index-000001", id: "0")
      true
  """
  @spec exists?(keyword()) :: boolean()
  def exists?(opts \\ []) when is_list(opts) do
    {index, document_id, opts} = extract_required_index_and_required_id!(opts)
    path = merge_path_items([index, :_doc, document_id])

    Client.head(path, nil, opts) == :ok
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
    path = merge_path_items([index, :_doc, document_id])

    Client.delete(path, nil, nil, opts)
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
    path = merge_path_items([index, :_update, document_id])

    Client.post(path, nil, document, opts)
  end

  ## Private functions

  @spec do_multi_get(binary(), :ids | :docs, [map()], keyword()) :: ElasticsearchEx.response()
  defp do_multi_get(_path, _key, [], _opts) do
    Logger.warning("No documents to fetch, returning empty list")

    {:ok, %{"docs" => []}}
  end

  defp do_multi_get(path, key, body, opts) do
    Client.post(path, nil, %{key => body}, opts)
  end

  @spec generate_mget_path(nil | binary()) :: binary()
  defp generate_mget_path(nil) do
    "/_mget"
  end

  defp generate_mget_path(index) do
    merge_path_items([index, :_mget])
  end

  @spec format_multi_get_ids(any()) :: [binary()] | no_return()
  defp format_multi_get_ids(ids) when is_struct(ids, Stream) do
    ids |> Enum.to_list() |> format_multi_get_ids()
  end

  defp format_multi_get_ids(ids) when is_list(ids) do
    unless Enum.all?(ids, &is_binary/1) do
      raise ArgumentError, "invalid option `ids`, must be a list of binaries"
    end

    ids
  end

  @spec format_multi_get_docs(any(), nil | binary() | atom()) :: [map()] | no_return()
  defp format_multi_get_docs(docs, index) when is_list(docs) or is_struct(docs, Stream) do
    Enum.map(docs, &do_format_multi_get_docs(&1, index))
  end

  defp format_multi_get_docs(_docs, nil) do
    raise ArgumentError, "invalid option `docs`, must be a non-empty list of maps, structs"
  end

  defp format_multi_get_docs(_docs, _index) do
    raise ArgumentError,
          "invalid option `docs`, must be a non-empty list of maps, structs or binaries"
  end

  @spec do_format_multi_get_docs(binary() | tuple() | map(), nil | binary() | atom()) ::
          map() | no_return()
  defp do_format_multi_get_docs(doc_id, _index) when is_binary(doc_id) do
    raise ArgumentError, "use the option `ids` instead of `docs`"
  end

  defp do_format_multi_get_docs({index, doc_id}, _index)
       when is_binary(doc_id) and (is_binary(index) or is_atom(index)) do
    %{_index: index, _id: doc_id}
  end

  defp do_format_multi_get_docs(doc, index) when is_map(doc) do
    formatted_doc =
      Enum.reduce(doc, %{}, fn
        {key, value}, acc when key in ~w[index _index]a ->
          Map.put(acc, :_index, value)

        {key, value}, acc when key in ~w[id _id]a ->
          Map.put(acc, :_id, value)

        {key, value}, acc when key in ~w[source _source]a ->
          Map.put(acc, :_source, value)

        {key, value}, acc when key in ~w[stored_fields _stored_fields]a ->
          Map.put(acc, :_source, value)

        {key, value}, acc when key == :routing ->
          Map.put(acc, :routing, value)

        {key, value}, _acc ->
          raise ArgumentError, "invalid key `#{key}`, value: `#{inspect(value)}`"
      end)

    unless Map.has_key?(formatted_doc, :_id) do
      raise ArgumentError, "missing option `id` in the map, got: `#{inspect(doc)}`"
    end

    unless not is_nil(index) or Map.has_key?(formatted_doc, :_index) do
      raise ArgumentError, "missing option `index` in the map, got: `#{inspect(doc)}`"
    end

    formatted_doc
  end
end
