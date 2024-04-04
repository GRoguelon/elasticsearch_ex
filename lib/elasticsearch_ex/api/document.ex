defmodule ElasticsearchEx.Api.Document do
  @moduledoc """
  Provides the APIs for the single document operations.
  """

  import ElasticsearchEx.Guards,
    only: [
      is_identifier: 1,
      is_name: 1,
      is_name!: 1
    ]

  require Logger

  alias ElasticsearchEx.Client

  ## Typespecs

  @type source :: ElasticsearchEx.source()

  @type document_id :: ElasticsearchEx.document_id()

  @type index :: ElasticsearchEx.index()

  @type opts :: ElasticsearchEx.opts()

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
  @doc since: "1.0.0"
  @spec index(source(), index(), nil | document_id(), opts()) :: ElasticsearchEx.response()
  def index(source, index, document_id \\ nil, opts \\ [])

  def index(source, index, nil, opts)
      when is_map(source) and is_name!(index) do
    Client.post("/#{index}/_doc", nil, source, opts)
  end

  def index(source, index, document_id, opts)
      when is_map(source) and is_name!(index) and is_identifier(document_id) do
    Client.put("/#{index}/_doc/#{document_id}", nil, source, opts)
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
  @doc since: "1.0.0"
  @spec create(source(), index(), document_id(), opts()) :: ElasticsearchEx.response()
  def create(source, index, document_id, opts \\ [])
      when is_map(source) and is_name!(index) and is_identifier(document_id) do
    Client.put("/#{index}/_create/#{document_id}", nil, source, opts)
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
  @doc since: "1.0.0"
  @spec get(index(), document_id(), opts()) :: ElasticsearchEx.response()
  def get(index, document_id, opts \\ [])
      when is_name!(index) and is_identifier(document_id) do
    Client.get("/#{index}/_doc/#{document_id}", nil, nil, opts)
  end

  @doc """
  Retrieves multiple JSON documents by ID.

  The argument `document_ids` expects a `List` of `binary`. It uses as body: `{"ids": ["id1", "id2"]}`.

  It raises an exception if the argument `index` is `nil`.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-multi-get.html#docs-multi-get-api-query-params)
  for a detailed list of the parameters.

  ### Examples

      iex> ElasticsearchEx.Api.Document.get_ids(["ArSqnI4BpDBWjw9UsTk-", "BrS8nI4BpDBWjw9UUTk5"], nil)
      ** (ArgumentError) the argument `index` cannot be `nil`

      iex> ElasticsearchEx.Api.Document.get_ids(["ArSqnI4BpDBWjw9UsTk-", "BrS8nI4BpDBWjw9UUTk5"], "my-index-000001")
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
             "found" => false
            }
         ]
       }}
  """
  @doc since: "1.0.0"
  @spec get_ids([document_id()], index(), opts()) :: ElasticsearchEx.response()
  def get_ids(document_ids, index, opts \\ [])

  def get_ids(_document_ids, nil, _opts) do
    raise ArgumentError, "the argument `index` cannot be `nil`"
  end

  def get_ids(document_ids, index, opts)
      when is_list(document_ids) and is_name!(index) do
    Enum.each(document_ids, fn document_id ->
      is_identifier(document_id) ||
        raise ArgumentError, "invalid value, expected a binary, got: `#{inspect(document_id)}`"
    end)

    Client.post("/#{index}/_mget", nil, %{ids: document_ids}, opts)
  end

  @doc """
  Retrieves multiple JSON documents by ID.

  The argument `documents` expects a `List` of `Map` where the key `:_id` is required and the key
  `:_index` is required if the argument `index` is `nil`. It uses as body: `{"docs": [{"_id": "id1"}, {"_id": "id2"}]}`.

  Only the following keys: `:_index`, `:_id`, `:_source`, `:_stored_fields` and `:routing` are
  allowed in the `Map`.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-multi-get.html#docs-multi-get-api-query-params)
  for a detailed list of the parameters.

  ### Examples

  Query with only IDs (the option `index` is required):

      iex> ElasticsearchEx.Api.Document.get_docs([
      ...>   %{_index: "my-index-000001", _id: "ArSqnI4BpDBWjw9UsTk-", _source: false},
      ...>   %{_index: "my-index-000001", _id: "BrS8nI4BpDBWjw9UUTk5"}
      ...> ])
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
             "found" => false
            }
         ]
       }}
  """
  @doc since: "1.0.0"
  @spec get_docs([map()], nil | index(), opts()) :: ElasticsearchEx.response()
  def get_docs(documents, index \\ nil, opts \\ [])
      when is_list(documents) and (is_nil(index) or is_name(index)) do
    Enum.each(documents, fn document ->
      unless is_map(document) do
        raise ArgumentError, "invalid value, expected a map, got: `#{inspect(document)}`"
      end

      unless is_map_key(document, :_id) do
        raise ArgumentError, "missing key `:_id` in the map, got: `#{inspect(document)}`"
      end

      unless not is_nil(index) or is_map_key(document, :_index) do
        raise ArgumentError, "missing key `:_index` in the map, got: `#{inspect(document)}`"
      end
    end)

    Client.post([index, "/_mget"], nil, %{docs: documents}, opts)
  end

  @doc """
  Retrieves multiple JSON documents by ID.

  It checks if the `values` are a list of binary and calls `get_ids/3` or a list of map and calls `get_docs/3`.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-multi-get.html#docs-multi-get-api-query-params)
  for a detailed list of the parameters.

  ### Examples

  Uses `get_docs/3`:

      iex> ElasticsearchEx.Api.Document.multi_get(
      ...>   [
      ...>     %{_index: "my-index-000001", _id: "ArSqnI4BpDBWjw9UsTk-", _source: false},
      ...>     %{_index: "my-index-000001", _id: "BrS8nI4BpDBWjw9UUTk5"}
      ...>   ],
      ...>   "my-index-000001",
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
             "found" => false
            }
         ]
       }}

  Uses `get_ids/3`:

      iex> ElasticsearchEx.Api.Document.multi_get(
      ...>   ["ArSqnI4BpDBWjw9UsTk-", "BrS8nI4BpDBWjw9UUTk5"],
      ...>   "my-index-000001",
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
             "found" => false
            }
         ]
       }}

  Raises an exception if not a list of map or a list of binary:

      iex> ElasticsearchEx.Api.Document.multi_get([{"my-index-000001", "BrS8nI4BpDBWjw9UUTk5"}, "my-index-000001"])
      ** (ArgumentError) invalid value, expected a list of maps or document IDs, got: `[{"my-index-000001", "BrS8nI4BpDBWjw9UUTk5"}, "my-index-000001"]`
  """
  @doc since: "1.0.0"
  @spec multi_get(list(), nil | index(), opts()) :: ElasticsearchEx.response()
  def multi_get(values, index \\ nil, opts \\ []) when is_list(values) do
    cond do
      Enum.all?(values, &is_map/1) ->
        get_docs(values, index, opts)

      Enum.all?(values, &is_identifier/1) ->
        get_ids(values, index, opts)

      true ->
        raise ArgumentError,
              "invalid value, expected a list of maps or document IDs, got: `#{inspect(values)}`"
    end
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
  @doc since: "1.0.0"
  @spec exists?(index(), document_id(), opts()) :: boolean()
  def exists?(index, document_id, opts \\ [])
      when is_name!(index) and is_identifier(document_id) do
    Client.head("/#{index}/_doc/#{document_id}", nil, opts) == :ok
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
  @doc since: "1.0.0"
  @spec delete(index(), document_id(), opts()) :: ElasticsearchEx.response()
  def delete(index, document_id, opts \\ [])
      when is_name!(index) and is_identifier(document_id) do
    Client.delete("/#{index}/_doc/#{document_id}", nil, nil, opts)
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
  @doc since: "1.0.0"
  @spec update(source(), index(), document_id(), opts()) :: ElasticsearchEx.response()
  def update(source, index, document_id, opts \\ [])
      when is_map(source) and is_name!(index) and is_identifier(document_id) do
    Client.post("/#{index}/_update/#{document_id}", nil, source, opts)
  end
end
