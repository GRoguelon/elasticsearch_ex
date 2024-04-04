defmodule ElasticsearchEx.ConnCase do
  @moduledoc """
  Provides a base to test the HTTP adapters
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import ElasticsearchEx.ConnCase
    end
  end

  ## Private functions

  def create_index(index_name, properties) do
    ElasticsearchEx.Client.delete("/#{index_name}", nil, nil)

    {:ok, _} =
      ElasticsearchEx.Client.put("/#{index_name}", nil, %{
        mappings: %{dynamic: :strict, properties: properties},
        settings: %{
          "index.number_of_shards": 1,
          "index.number_of_replicas": 0,
          "index.refresh_interval": -1
        }
      })

    :ok
  end

  def generate_id, do: :crypto.strong_rand_bytes(15) |> Base.url_encode64(padding: false)

  def delete_index(index_name) do
    {:ok, _} = ElasticsearchEx.Client.delete("/#{index_name}", nil, nil)

    :ok
  end

  def index_documents(index_name, times) do
    doc_ids =
      Enum.map(1..times, fn i ->
        {:ok, %{"_id" => doc_id}} =
          ElasticsearchEx.Api.Document.index(%{message: "Hello World #{i}!"}, index_name)

        doc_id
      end)

    {:ok, _} = ElasticsearchEx.Client.get("/#{index_name}/_refresh", nil, nil)

    doc_ids
  end
end
