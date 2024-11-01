defmodule ElasticsearchEx.API.Features do
  @moduledoc """
  You can use the following APIs to introspect and manage Features provided by Elasticsearch and
  Elasticsearch plugins.
  """

  import ElasticsearchEx.Client, only: [request: 4]

  ## Typespecs

  @type opts :: ElasticsearchEx.opts()

  ## Public functions

  @doc """
  Gets a list of features which can be included in snapshots using the [`feature_states` field](https://www.elastic.co/guide/en/elasticsearch/reference/current/create-snapshot-api.html#create-snapshot-api-feature-states) when creating a snapshot.

  ### Examples

      iex> ElasticsearchEx.API.Features.get()
      {:ok,
       %{
         "features" => [
           %{
             "description" => "Manages Kibana configuration and reports",
             "name" => "kibana"
           },
           %{"description" => "Manages synonyms", "name" => "synonyms"}
         ]
       }}
  """
  @doc since: "1.5.0"
  @spec get(opts()) :: ElasticsearchEx.response()
  def get(opts \\ []) do
    request(:get, "_features", nil, opts)
  end

  @doc """
  Clears all of the state information stored in system indices by Elasticsearch features, including
  the security and machine learning indices.

  > #### Important {: .warning}
  >
  > Intended for development and testing use only. Do not reset features on a production cluster.

  ### Examples

      iex> ElasticsearchEx.API.Features.reset()
      {:ok,
       %{
         "features" => [
           %{
             "feature_name" => "security",
             "status" => "SUCCESS"
           },
           %{
             "feature_name" => "tasks",
             "status" => "SUCCESS"
           }
         ]
       }}
  """
  @doc since: "1.5.0"
  @spec reset(opts()) :: ElasticsearchEx.response()
  def reset(opts \\ []) do
    request(:post, "_features/_reset", nil, opts)
  end
end
