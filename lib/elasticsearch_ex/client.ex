defmodule ElasticsearchEx.Client do
  @moduledoc """
  Provides functions to make HTTP requests to an Elasticsearch cluster.

  This module handles HTTP requests (GET, POST, PUT, DELETE, HEAD) to Elasticsearch, supporting
  JSON and NDJSON content types. Cluster configuration is
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
  - `:keys_as_atoms`: Set to `true` to convert string keys to atoms.
  - `:deserialize`: Set to `true` to deserialize responses using `ElasticsearchEx.Deserializer`.

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

  require Logger

  alias ElasticsearchEx.Deserializer
  alias ElasticsearchEx.MapExt

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
  Request options, including `:cluster`, `:headers`, `:req_opts`, `:ndjson`, `:keys`, `:deserialize`, `:mapper`.
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
      request(:get, "/my_index/_doc/1", nil, mapper: mapper)
      # => {:ok, %{"_index" => "my_index", "_source" => %{"field" => "value"}}}
  """
  @spec request(method(), path(), body(), opts()) :: {:ok, term()} | {:error, Exception.t()}
  def request(method, path, body \\ nil, opts \\ []) do
    {cluster_config, opts} = get_cluster_configuration(opts)
    {url, auth} = generate_request_url_and_auth(cluster_config, path)
    {headers, opts} = generate_request_headers(cluster_config, opts)
    {body_key, body_value} = generate_request_body(body, headers)
    {deserialize, opts} = Keyword.pop(opts, :deserialize)
    {keys_as_atoms, opts} = Keyword.pop(opts, :keys_as_atoms)
    {req_opts, opts} = generate_request_options(cluster_config, opts)
    {params, remaining_opts} = Keyword.pop(opts, :params, [])

    if remaining_opts != [] do
      Logger.warning(
        "Wrap `#{inspect(remaining_opts)}` into: `params: #{inspect(remaining_opts)}`"
      )
    end

    if req_opts[:decode_json][:keys] == :atoms and deserialize == true do
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
      {:params, Keyword.merge(params, remaining_opts)}
    ]
    |> Req.new()
    |> Req.merge(req_opts)
    # |> Req.Request.append_request_steps(inspect: &IO.inspect/1)
    |> Req.request()
    |> parse_result(deserialize, keys_as_atoms)
  end

  ## Private functions

  @spec parse_result(ElasticsearchEx.response(), boolean(), boolean()) ::
          ElasticsearchEx.response()
  defp parse_result({:ok, %Req.Response{body: %{"error" => _}} = response}, _, _) do
    {:error, ElasticsearchEx.Error.exception(response)}
  end

  defp parse_result(
         {:ok, %Req.Response{status: status, body: body}},
         deserialize,
         keys_as_atoms
       )
       when status in 200..299 do
    key_mapper =
      if keys_as_atoms do
        &String.to_atom/1
      else
        &Function.identity/1
      end

    result =
      cond do
        deserialize ->
          Deserializer.deserialize(body, key_mapper)

        is_list(body) or is_map(body) ->
          MapExt.map_keys(body, key_mapper)

        true ->
          body
      end

    {:ok, result}
  end

  defp parse_result({:ok, %Req.Response{status: status} = response}, _, _)
       when status in 300..599 do
    {:error, ElasticsearchEx.Error.exception(response)}
  end

  defp parse_result({:error, error}, _, _) when is_exception(error) do
    {:error, error}
  end

  defp parse_result({:error, error}, _, _) do
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
    {request_req_opts, opts} = Keyword.pop(opts, :req_opts, [])
    req_opts = Keyword.merge(global_req_opts, request_req_opts)

    {req_opts, opts}
  end
end
