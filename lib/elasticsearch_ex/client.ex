defmodule ElasticsearchEx.Client do
  @moduledoc false

  ## Typespecs

  @type response :: {:ok, term()}

  ## Module attributes

  @default_url Application.compile_env(:elasticsearch_ex, :url) |> URI.new!()

  @content_type_key "content-type"

  @application_json "application/json"

  @default_headers %{@content_type_key => @application_json}

  @success_code 200..299

  ## Public functions

  def request(method, path, headers \\ nil, body \\ nil, opts \\ []) do
    uri = @default_url |> URI.merge(path)
    headers = prepare_headers(uri, headers)
    body = prepare_body!(headers, body)

    case AnyHttp.request(method, uri, headers, body, opts) do
      {:ok, %AnyHttp.Response{status: status, headers: headers, body: body}}
      when status in @success_code ->
        body =
          if json_response?(headers) and is_binary(body) do
            Jason.decode!(body)
          else
            body
          end

        {:ok, body}

      any ->
        raise "Invalid response: #{inspect(any)}"
    end
  end

  @spec head(binary(), nil | map(), keyword()) :: :ok
  def head(path, headers \\ nil, opts \\ []) do
    case request(:head, path, headers, nil, opts) do
      {:ok, nil} ->
        :ok

      others ->
        others
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

  @spec json_response?(map()) :: boolean()
  defp json_response?(headers) when is_map(headers) do
    Map.get(headers, @content_type_key) == [@application_json]
  end

  @spec prepare_headers(URI.t(), nil | any()) :: map()
  defp prepare_headers(uri, nil), do: prepare_headers(uri, @default_headers)

  defp prepare_headers(%URI{userinfo: userinfo}, headers) when is_binary(userinfo) do
    Map.put(headers, "authorization", "Basic #{Base.encode64(userinfo)}")
  end

  defp prepare_headers(_uri, headers), do: headers

  @spec prepare_body!(map(), any()) :: any()
  defp prepare_body!(%{@content_type_key => content_type}, body)
       when content_type == @application_json and not is_nil(body) do
    Jason.encode!(body)
  end

  defp prepare_body!(_headers, body), do: body
end
