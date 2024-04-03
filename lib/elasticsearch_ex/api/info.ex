defmodule ElasticsearchEx.Api.Info do
  @moduledoc """
  Provides general information about the installed X-Pack features.
  """

  alias ElasticsearchEx.Client

  ## Typespecs

  @type opts :: ElasticsearchEx.opts()

  ## Public functions

  @doc """
  Provides general information about the installed X-Pack features.

  ### Examples

      iex> ElasticsearchEx.Api.Info.xpack()
      {:ok,
       %{
         "build" => %{
           "date" => "2024-02-19T10:04:32.774273190Z",
           "hash" => "48a287ab9497e852de30327444b0809e55d46466"
         },
         "features" => %{
           "aggregate_metric" => %{"available" => true, "enabled" => true},
           "analytics" => %{"available" => true, "enabled" => true},
           "archive" => %{"available" => false, "enabled" => true},
           "ccr" => %{"available" => false, "enabled" => true},
           "data_streams" => %{"available" => true, "enabled" => true},
           "data_tiers" => %{"available" => true, "enabled" => true},
           "enrich" => %{"available" => true, "enabled" => true},
           "enterprise_search" => %{"available" => false, "enabled" => true},
           "eql" => %{"available" => true, "enabled" => true},
           "esql" => %{"available" => true, "enabled" => true},
           "frozen_indices" => %{"available" => true, "enabled" => true},
           "graph" => %{"available" => false, "enabled" => true},
           "ilm" => %{"available" => true, "enabled" => true},
           "logstash" => %{"available" => false, "enabled" => true},
           "ml" => %{"available" => false, "enabled" => true},
           "monitoring" => %{"available" => true, "enabled" => true},
           "rollup" => %{"available" => true, "enabled" => true},
           "searchable_snapshots" => %{"available" => false, "enabled" => true},
           "security" => %{"available" => true, "enabled" => true},
           "slm" => %{"available" => true, "enabled" => true},
           "spatial" => %{"available" => true, "enabled" => true},
           "sql" => %{"available" => true, "enabled" => true},
           "transform" => %{"available" => true, "enabled" => true},
           "universal_profiling" => %{"available" => false, "enabled" => true},
           "voting_only" => %{"available" => true, "enabled" => true},
           "watcher" => %{"available" => false, "enabled" => true}
         },
         "license" => %{
           "mode" => "basic",
           "status" => "active",
           "type" => "basic",
           "uid" => "bc87523c-7692-4955-a01a-0aa596920c9c"
         },
         "tagline" => "You know, for X"
       }}
  """
  @doc since: "1.2.0"
  @spec xpack(opts()) :: ElasticsearchEx.response()
  def xpack(opts \\ []) do
    Client.get("/_xpack", nil, nil, opts)
  end
end
