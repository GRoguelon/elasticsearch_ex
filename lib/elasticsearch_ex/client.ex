defmodule ElasticsearchEx.Client do
  @moduledoc """
  Provides the functions to make HTTP calls.
  """

  ## Typespecs

  @type method :: :head | :get | :post | :put | :delete

  @type path :: iodata()

  @type headers :: %{binary() => binary()}

  @type body :: any()

  @type opts :: keyword()

  @type cluster_config :: %{
          required(:endpoint) => binary(),
          optional(:headers) => headers(),
          optional(:req_opts) => keyword()
        }

  ## Module attributes

  @configured_clusters Application.compile_env!(:elasticsearch_ex, :clusters)

  @content_type_key "content-type"

  @application_json "application/json"

  @application_ndjson "application/x-ndjson"

  ## Public functions

  @spec request(method(), path(), body(), opts()) :: any()
  def request(method, path, body \\ nil, opts \\ []) do
    {cluster_config, opts} = get_cluster_configuration(opts)
    {url, auth} = generate_request_url_and_auth(cluster_config, path)
    {headers, opts} = generate_request_headers(cluster_config, opts)
    {body_key, body_value} = generate_request_body(body, headers)
    {req_opts, query_params} = generate_request_options(cluster_config, opts)

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
    |> parse_result()
  end

  ## Private functions

  defp parse_result({:ok, %Req.Response{status: status, body: body}}) when status in 200..299 do
    {:ok, body}
  end

  defp parse_result({:ok, %Req.Response{status: status} = response}) when status in 300..599 do
    {:error, ElasticsearchEx.Error.exception(response)}
  end

  defp parse_result({:error, error}) when is_exception(error) do
    {:error, error}
  end

  defp parse_result({:error, error}) do
    raise "Unknown error: #{inspect(error)}"
  end

  # Extract the Elasticsearch configuration from the library configuration.
  @spec get_cluster_configuration(opts()) :: {cluster_config(), opts()}
  defp get_cluster_configuration(opts) do
    case Keyword.pop(opts, :cluster, :default) do
      {cluster_configuration, opts} when is_map(cluster_configuration) ->
        {cluster_configuration, opts}

      {cluster_name, opts}
      when is_atom(cluster_name) and is_map_key(@configured_clusters, cluster_name) ->
        cluster_configuration = Map.fetch!(@configured_clusters, cluster_name)

        {cluster_configuration, opts}

      _ ->
        raise "unable to find the cluster configuration"
    end
  end

  @spec generate_request_url_and_auth(cluster_config(), path()) ::
          {URI.t(), nil | {:basic, binary()}}
  defp generate_request_url_and_auth(%{endpoint: endpoint}, path) do
    path_as_str = to_string(path)
    uri = endpoint |> URI.new!() |> uri_append_path(path_as_str)
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

  @spec uri_append_path(URI.t(), binary()) :: URI.t()
  defp uri_append_path(%URI{} = uri, <<"/", _::binary>> = path) do
    ElasticsearchEx.Utils.uri_append_path(uri, path)
  end

  defp uri_append_path(%URI{} = uri, path) when is_binary(path) do
    ElasticsearchEx.Utils.uri_append_path(uri, "/" <> path)
  end
end
