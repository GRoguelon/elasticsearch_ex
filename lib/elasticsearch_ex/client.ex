defmodule ElasticsearchEx.Client do
  @moduledoc false

  ## Typespecs

  @type response :: {:ok, term()} | {:error, ElasticsearchEx.Error.t()}

  ## Module attributes

  @default_url Application.compile_env(:elasticsearch_ex, :url) |> URI.new!()

  @content_type_key "content-type"

  @application_json "application/json"

  @default_headers %{@content_type_key => @application_json}

  ## Public functions

  def request(method, path, headers \\ nil, body \\ nil, opts \\ []) do
    {http_opts, query} = Keyword.pop(opts, :http_opts, [])
    uri = prepare_uri(path, query)
    headers = prepare_headers(uri, headers)
    body = prepare_body!(headers, body)
    uri = %{uri | userinfo: nil}
    result = AnyHttp.request(method, uri, headers, body, http_opts)

    # uri |> URI.to_string() |> IO.inspect(label: "URL")

    result |> maybe_decode_json_body!() |> parse_result()
  end

  @spec head(binary(), nil | map(), keyword()) :: :ok | :error
  def head(path, headers \\ nil, opts \\ []) do
    case request(:head, path, headers, nil, opts) do
      {:ok, nil} ->
        :ok

      {:error, %ElasticsearchEx.Error{}} ->
        :error
    end
  end

  @spec get(binary(), nil | map(), any(), keyword()) :: {:ok, term()}
  def get(path, headers \\ nil, body \\ nil, opts \\ []) do
    request(:get, path, headers, body, opts)
  end

  @spec post(binary(), nil | map(), any(), keyword()) :: {:ok, term()}
  def post(path, headers \\ nil, body \\ nil, opts \\ []) do
    request(:post, path, headers, body, opts)
  end

  @spec put(binary(), nil | map(), any(), keyword()) :: {:ok, term()}
  def put(path, headers \\ nil, body \\ nil, opts \\ []) do
    request(:put, path, headers, body, opts)
  end

  @spec patch(binary(), nil | map(), any(), keyword()) :: {:ok, term()}
  def patch(path, headers \\ nil, body \\ nil, opts \\ []) do
    request(:patch, path, headers, body, opts)
  end

  @spec delete(binary(), nil | map(), any(), keyword()) :: {:ok, term()}
  def delete(path, headers \\ nil, body \\ nil, opts \\ []) do
    request(:delete, path, headers, body, opts)
  end

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

  @spec prepare_uri(binary(), keyword()) :: URI.t()
  defp prepare_uri(path, []) do
    URI.merge(@default_url, path)
  end

  defp prepare_uri(path, query) do
    uri_query = URI.encode_query(query)

    @default_url |> URI.merge(path) |> then(&%{&1 | query: uri_query})
  end

  @spec prepare_headers(URI.t(), nil | any()) :: map()
  defp prepare_headers(uri, nil), do: prepare_headers(uri, @default_headers)

  defp prepare_headers(%URI{userinfo: userinfo}, headers) when is_binary(userinfo) do
    Map.put(headers, "authorization", "Basic #{Base.encode64(userinfo)}")
  end

  defp prepare_headers(_uri, headers) when is_map(headers) do
    @default_headers |> Map.merge(headers) |> Map.reject(fn {_key, value} -> is_nil(value) end)
  end

  defp prepare_headers(_uri, headers) when is_list(headers) do
    keys = Enum.map(headers, fn {key, _value} -> key end)

    default_headers =
      @default_headers |> Map.reject(fn {key, _value} -> key in keys end) |> Enum.to_list()

    Enum.reject(default_headers ++ headers, fn {_key, value} -> is_nil(value) end)
  end

  @spec prepare_body!(map(), any()) :: any()
  defp prepare_body!(%{@content_type_key => content_type}, body)
       when content_type == @application_json and not is_nil(body) do
    Jason.encode!(body)
  end

  defp prepare_body!(_headers, body), do: body
end
