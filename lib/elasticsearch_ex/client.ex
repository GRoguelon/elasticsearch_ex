defmodule ElasticsearchEx.Client do
  @moduledoc """
  Provides the functions to make HTTP calls.
  """

  ## Module attributes

  @content_type_key "content-type"

  @application_json "application/json"

  @application_ndjson "application/x-ndjson"

  @default_headers %{@content_type_key => @application_json}

  ## Public functions

  def request(method, path, headers, body, opts \\ []) do
    {cluster, opts} = get_cluster_configuration(opts)
    {http_opts, query} = prepare_options(cluster, opts)
    uri = prepare_uri(cluster, path, query)
    {headers, uri} = prepare_headers(cluster, uri, headers || @default_headers)
    body = prepare_body!(headers, body)

    # URI.to_string(uri) |> IO.inspect(label: "URL")

    AnyHttp.request(method, uri, headers, body, http_opts)
    |> maybe_decode_json_body!()
    |> parse_result()
  end

  def head(path, headers \\ nil, opts \\ []) do
    case request(:head, path, headers, nil, opts) do
      {:ok, nil} ->
        :ok

      {:error, %ElasticsearchEx.Error{}} ->
        :error
    end
  end

  def get(path, headers \\ nil, body \\ nil, opts \\ []) do
    request(:get, path, headers, body, opts)
  end

  def post(path, headers \\ nil, body \\ "", opts \\ []) do
    request(:post, path, headers, body, opts)
  end

  def put(path, headers \\ nil, body \\ nil, opts \\ []) do
    request(:put, path, headers, body, opts)
  end

  def delete(path, headers \\ nil, body \\ nil, opts \\ []) do
    request(:delete, path, headers, body, opts)
  end

  @doc false
  def json, do: %{@content_type_key => @application_json}

  @doc false
  def ndjson, do: %{@content_type_key => @application_ndjson}

  ## Private functions

  defp parse_result({:ok, %{status: status, body: body}}) when status in 200..299 do
    {:ok, body}
  end

  defp parse_result({:ok, %{status: status} = response}) when status in 300..599 do
    {:error, ElasticsearchEx.Error.exception(response)}
  end

  defp parse_result({:error, error}) do
    raise "Unknown error: #{inspect(error)}"
  end

  defp maybe_decode_json_body!({:ok, %{headers: headers, body: body} = response} = result) do
    content_type = Map.get(headers, @content_type_key)

    if content_type == [@application_json] and is_binary(body) and body != "" do
      {:ok, %{response | body: Jason.decode!(body)}}
    else
      result
    end
  end

  defp maybe_decode_json_body!(any), do: any

  defp get_cluster_configuration(opts) do
    {cluster, opts} = Keyword.pop(opts, :cluster, :default)

    if is_map(cluster) do
      {cluster, opts}
    else
      clusters_configuration = Application.fetch_env!(:elasticsearch_ex, :clusters)
      cluster_configuration = Map.fetch!(clusters_configuration, cluster)

      {cluster_configuration, opts}
    end
  end

  defp prepare_uri(cluster, path, []) do
    cluster |> Map.fetch!(:endpoint) |> URI.new!() |> URI.merge(path)
  end

  defp prepare_uri(cluster, path, query) do
    uri_query = URI.encode_query(query)
    uri = prepare_uri(cluster, path, [])

    %{uri | query: uri_query}
  end

  defp prepare_options(cluster, opts) do
    global_http_opts = Map.get(cluster, :http_opts, [])
    {http_opts, query} = Keyword.pop(opts, :http_opts, [])
    http_opts = Keyword.merge(global_http_opts, http_opts)

    {http_opts, query}
  end

  defp prepare_headers(cluster, uri, headers) when is_map(headers) do
    headers =
      (Map.get(cluster, :headers) || %{})
      |> Map.merge(headers)
      |> Map.reject(fn {_key, value} -> is_nil(value) end)

    if is_binary(uri.userinfo) do
      headers = Map.put(headers, "authorization", "Basic #{Base.encode64(uri.userinfo)}")
      uri = %{uri | userinfo: nil}

      {headers, uri}
    else
      {headers, uri}
    end
  end

  defp prepare_body!(%{@content_type_key => @application_json}, body)
       when not is_nil(body) and body != "" do
    Jason.encode!(body)
  end

  defp prepare_body!(%{@content_type_key => @application_ndjson}, body)
       when not is_nil(body) and body != "" do
    ElasticsearchEx.Ndjson.encode!(body)
  end

  defp prepare_body!(_headers, body), do: body
end
