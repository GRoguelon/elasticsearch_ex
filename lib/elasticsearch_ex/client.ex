defmodule ElasticsearchEx.Client do
  @moduledoc """
  Provides functions to make HTTP requests to an Elasticsearch cluster.

  This module handles HTTP requests (GET, POST, PUT, DELETE, HEAD) to Elasticsearch, supporting
  JSON and NDJSON content types. It integrates with `ElasticsearchEx.MappingsCacher` for automatic
  deserialization of responses (via `:deserialize` and `:deserializer` options) and
  `ElasticsearchEx.MapExt` for key transformation (via `:keys` option). Cluster configuration is
  fetched from the `:elasticsearch_ex` application environment or provided via options.

  ## Configuration
  Configure clusters in `config.exs`:
      config :elasticsearch_ex, :clusters,
        default: %{
          endpoint: "http://localhost:9200",
          headers: %{"x-custom-header" => "value"},
          req_opts: [timeout: 5000]
        }

  ## Supported Options
  - `:cluster`: Cluster name (atom) or configuration map (defaults to `:default`).
  - `:headers`: Additional HTTP headers (map).
  - `:req_opts`: Req library options (e.g., `[timeout: 5000]`).
  - `:ndjson`: Set to `true` for NDJSON content type.
  - `:keys`: Set to `:atoms` to convert string keys to atoms using `ElasticsearchEx.MapExt`.
  - `:deserialize`: Set to `true` to deserialize responses using `ElasticsearchEx.Deserializer` with `ElasticsearchEx.MappingsCacher`.
  - `:deserializer`: Custom function (`index -> mappings`) for deserialization.

  ## Examples
      # GET request
      request(:get, "/my_index/_search")
      # => {:ok, %{"hits" => ...}}

      # POST request with JSON body
      request(:post, "/my_index/_doc", %{"field" => "value"})
      # => {:ok, %{"_id" => ...}}

      # NDJSON bulk request
      request(:post, "/_bulk", [%{"index" => %{"_index" => "my_index"}}, %{"field" => "value"}], ndjson: true)
      # => {:ok, %{"items" => ...}}

      # Deserialize with mappings
      request(:get, "/my_index/_doc/1", nil, deserialize: true)
      # => {:ok, %{"_index" => "my_index", "_source" => %{"field" => value}}}
  """

  ## Typespecs

  @typedoc """
  HTTP method for the request.
  """
  @type method :: :head | :get | :post | :put | :delete

  @typedoc """
  URL path for the Elasticsearch endpoint (e.g., "/index/_search").
  """
  @type path :: iodata()

  @typedoc """
  HTTP headers as a string-keyed map.
  """
  @type headers :: %{binary() => binary()}

  @typedoc """
  Request body, typically a map, list, or nil for JSON/NDJSON encoding.
  """
  @type body :: any()

  @typedoc """
  Request options, including `:cluster`, `:headers`, `:req_opts`, `:ndjson`, `:keys`, `:deserialize`, `:deserializer`.
  """
  @type opts :: keyword()

  @typedoc """
  Cluster configuration with a required `:endpoint` (URL string) and optional `:headers` and `:req_opts`.
  """
  @type cluster_config :: %{
          required(:endpoint) => binary(),
          optional(:headers) => headers(),
          optional(:req_opts) => keyword()
        }

  ## Module attributes

  @content_type_key "content-type"

  @application_json "application/json"

  @application_ndjson "application/x-ndjson"

  ## Public functions

  @doc """
  Makes an HTTP request to an Elasticsearch cluster.

  ## Parameters
  - `method`: HTTP method (`:head`, `:get`, `:post`, `:put`, `:delete`).
  - `path`: URL path (e.g., `"/index/_search"`).
  - `body`: Request body (map, list, or nil; defaults to nil).
  - `opts`: Options for cluster, headers, deserialization, etc. See module documentation for details.

  ## Returns
  - `{:ok, term()}`: Successful response, potentially deserialized.
  - `{:error, Exception.t()}`: HTTP error (status 300-599) or network error.

  ## Examples
      # Simple GET request
      request(:get, "/my_index/_mapping")
      # => {:ok, %{"my_index" => %{"mappings" => ...}}}

      # POST with JSON body and atom keys
      request(:post, "/my_index/_doc", %{"field" => "value"}, keys: :atoms)
      # => {:ok, %{_id: "...", _source: %{field: "value"}}}

      # Bulk NDJSON request
      body = [%{"index" => %{"_index" => "my_index"}}, %{"field" => "value"}]
      request(:post, "/_bulk", body, ndjson: true)
      # => {:ok, %{"items" => ...}}

      # Deserialize with custom mapper
      mapper = fn _index -> %{"properties" => %{"field" => %{"type" => "text"}}} end
      request(:get, "/my_index/_doc/1", nil, deserializer: mapper)
      # => {:ok, %{"_index" => "my_index", "_source" => %{"field" => "value"}}}
  """
  @spec request(method(), path(), body(), opts()) :: {:ok, term()} | {:error, Exception.t()}
  def request(method, path, body \\ nil, opts \\ []) do
    {cluster_config, opts} = get_cluster_configuration(opts)
    {url, auth} = generate_request_url_and_auth(cluster_config, path)
    {headers, opts} = generate_request_headers(cluster_config, opts)
    {body_key, body_value} = generate_request_body(body, headers)
    {keys_atoms, opts} = Keyword.pop(opts, :keys)
    {deserialize, opts} = Keyword.pop(opts, :deserialize)
    {deserializer, opts} = Keyword.pop(opts, :deserializer)
    {req_opts, query_params} = generate_request_options(cluster_config, opts)
    req_keys_atoms = get_in(req_opts, [:decode_json, :keys])
    # IO.inspect(cluster_config, label: "Clust")
    # IO.inspect(url, label: "URL")

    # IO.inspect(req_opts, label: "Req opts")

    if req_keys_atoms == :atoms and (deserialize == true or is_function(deserializer, 1)) do
      raise ArgumentError,
            "replace the req option `[decode_json: [keys: :atoms]]` by `keys: :atoms`"
    end

    [
      {:method, method},
      {:url, url},
      {:auth, auth},
      {:headers, headers},
      {body_key, body_value},
      {:compress_body, body_value != ""},
      {:compressed, true},
      {:params, query_params}
    ]
    |> Req.new()
    |> Req.merge(req_opts)
    # |> Req.Request.append_request_steps(inspect: &IO.inspect/1)
    |> Req.request()
    |> parse_result(deserialize, deserializer, keys_atoms)
  end

  ## Private functions

  @spec maybe_deserialize_documents(term(), nil | true, nil | (binary() -> map()), nil | :atoms) ::
          term()
  defp maybe_deserialize_documents(result, _deserialize, _deserializer, _keys_atoms)
       when not is_map(result) do
    result
  end

  defp maybe_deserialize_documents(any_result, true, nil, keys_atoms) do
    deserializer = &ElasticsearchEx.MappingsCacher.get/1

    maybe_deserialize_documents(any_result, true, deserializer, keys_atoms)
  end

  defp maybe_deserialize_documents(result, deserialize, deserializer, keys_atoms)
       when is_function(deserializer, 1) and (is_nil(deserialize) or deserialize == true) do
    key_fun = if(keys_atoms == :atoms, do: &String.to_atom/1, else: &Function.identity/1)

    ElasticsearchEx.Deserializer.deserialize(result, deserializer, key_fun)
  end

  defp maybe_deserialize_documents(_result, _deserialize, deserializer, _keys_atoms)
       when not is_nil(deserializer) do
    raise ArgumentError,
          "option `deserializer` must be `nil` or a function of arity 1, got: `#{inspect(deserializer)}`"
  end

  defp maybe_deserialize_documents(result, _deserialize, _deserializer, :atoms) do
    ElasticsearchEx.MapExt.atomize_keys(result)
  end

  defp maybe_deserialize_documents(any_result, _deserialize, _deserializer, _keys_atoms) do
    any_result
  end

  @spec parse_result(
          ElasticsearchEx.response(),
          nil | true,
          nil | (binary() -> map()),
          nil | :atoms
        ) :: ElasticsearchEx.response()
  defp parse_result({:ok, %Req.Response{body: %{"error" => _}} = response}, _, _, _) do
    {:error, ElasticsearchEx.Error.exception(response)}
  end

  defp parse_result(
         {:ok, %Req.Response{status: status, body: body}},
         deserialize,
         deserializer,
         keys_atoms
       )
       when status in 200..299 do
    {:ok, maybe_deserialize_documents(body, deserialize, deserializer, keys_atoms)}
  end

  defp parse_result({:ok, %Req.Response{status: status} = response}, _, _, _)
       when status in 300..599 do
    {:error, ElasticsearchEx.Error.exception(response)}
  end

  defp parse_result({:error, error}, _, _, _) when is_exception(error) do
    {:error, error}
  end

  defp parse_result({:error, error}, _, _, _) do
    raise "Unknown error: #{inspect(error)}"
  end

  # Extract the Elasticsearch configuration from the library configuration.
  @spec get_cluster_configuration(opts()) :: {cluster_config(), opts()}
  defp get_cluster_configuration(opts) do
    configured_clusters = Application.fetch_env!(:elasticsearch_ex, :clusters)

    case Keyword.pop(opts, :cluster, :default) do
      {cluster_configuration, opts} when is_map(cluster_configuration) ->
        {cluster_configuration, opts}

      {cluster_name, opts}
      when is_atom(cluster_name) and is_map_key(configured_clusters, cluster_name) ->
        cluster_configuration = Map.fetch!(configured_clusters, cluster_name)

        {cluster_configuration, opts}

      _ ->
        raise "unable to find the cluster configuration"
    end
  end

  @spec generate_request_url_and_auth(cluster_config(), path()) ::
          {URI.t(), nil | {:basic, binary()}}
  defp generate_request_url_and_auth(%{endpoint: endpoint}, path) do
    path_as_str = path |> to_string() |> ElasticsearchEx.Utils.maybe_leading_slash()
    uri = endpoint |> URI.new!() |> ElasticsearchEx.Utils.uri_append_path(path_as_str)
    auth = uri.userinfo && {:basic, uri.userinfo}

    {%{uri | userinfo: nil}, auth}
  end

  @spec generate_request_headers(cluster_config(), opts()) :: {headers(), opts()}
  defp generate_request_headers(cluster_config, opts) do
    global_headers = Map.get(cluster_config, :headers, %{})
    {request_headers, opts} = Keyword.pop(opts, :headers, %{})
    {is_ndjson, opts} = Keyword.pop(opts, :ndjson, false)
    content_type_value = if(is_ndjson, do: @application_ndjson, else: @application_json)

    headers =
      %{@content_type_key => content_type_value}
      |> Map.merge(global_headers)
      |> Map.merge(request_headers)
      |> Map.reject(fn {_key, value} -> is_nil(value) end)

    {headers, opts}
  end

  @spec generate_request_body(body(), headers()) :: {:json | :body, any()}
  defp generate_request_body(body, headers) do
    cond do
      is_nil(body) ->
        {:body, ""}

      Map.fetch!(headers, @content_type_key) == @application_ndjson ->
        body = ElasticsearchEx.Ndjson.encode!(body)

        {:body, body}

      Map.fetch!(headers, @content_type_key) == @application_json ->
        {:json, body}

      true ->
        {:body, body}
    end
  end

  @spec generate_request_options(cluster_config(), opts()) :: {keyword(), keyword()}
  defp generate_request_options(cluster_config, opts) do
    global_req_opts = Map.get(cluster_config, :req_opts, [])
    {request_req_opts, query_params} = Keyword.pop(opts, :req_opts, [])
    req_opts = Keyword.merge(global_req_opts, request_req_opts)

    {req_opts, query_params}
  end
end
