defmodule ElasticsearchEx.Api.Usage do
  @moduledoc """
  Provides usage information about the installed X-Pack features.
  """

  alias ElasticsearchEx.Client

  ## Typespecs

  @type opts :: ElasticsearchEx.opts()

  ## Public functions

  @doc """
  Provides usage information about the installed X-Pack features.

  ### Examples

      iex> ElasticsearchEx.Api.Usage.xpack()
      {:ok,
       %{
         "aggregate_metric" => %{"available" => true, "enabled" => true},
         "analytics" => %{
           "available" => true,
           "enabled" => true,
           "stats" => %{
             "boxplot_usage" => 0,
             "cumulative_cardinality_usage" => 0,
             "moving_percentiles_usage" => 0,
             "multi_terms_usage" => 0,
             "normalize_usage" => 0,
             "rate_usage" => 0,
             "string_stats_usage" => 0,
             "t_test_usage" => 0,
             "top_metrics_usage" => 0
           }
         },
         "archive" => %{"available" => true, "enabled" => true, "indices_count" => 0},
         "ccr" => %{
           "auto_follow_patterns_count" => 0,
           "available" => true,
           "enabled" => true,
           "follower_indices_count" => 0
         },
         "data_lifecycle" => %{
           "available" => true,
           "count" => 0,
           "default_rollover_used" => true,
           "enabled" => true,
           "retention" => %{
             "average_millis" => 0.0,
             "maximum_millis" => 0,
             "minimum_millis" => 0
           }
         },
         "data_streams" => %{
           "available" => true,
           "data_streams" => 0,
           "enabled" => true,
           "indices_count" => 0
         },
         "data_tiers" => %{
           "available" => true,
           "data_cold" => %{
             "doc_count" => 0,
             "index_count" => 0,
             "node_count" => 0,
             "primary_shard_count" => 0,
             "primary_shard_size_avg_bytes" => 0,
             "primary_shard_size_mad_bytes" => 0,
             "primary_shard_size_median_bytes" => 0,
             "primary_size_bytes" => 0,
             "total_shard_count" => 0,
             "total_size_bytes" => 0
           },
           "data_content" => %{
             "doc_count" => 0,
             "index_count" => 0,
             "node_count" => 0,
             "primary_shard_count" => 0,
             "primary_shard_size_avg_bytes" => 0,
             "primary_shard_size_mad_bytes" => 0,
             "primary_shard_size_median_bytes" => 0,
             "primary_size_bytes" => 0,
             "total_shard_count" => 0,
             "total_size_bytes" => 0
           },
           "data_frozen" => %{
             "doc_count" => 0,
             "index_count" => 0,
             "node_count" => 1,
             "primary_shard_count" => 0,
             "primary_shard_size_avg_bytes" => 0,
             "primary_shard_size_mad_bytes" => 0,
             "primary_shard_size_median_bytes" => 0,
             "primary_size_bytes" => 0,
             "total_shard_count" => 0,
             "total_size_bytes" => 0
           },
           "data_hot" => %{
             "doc_count" => 0,
             "index_count" => 0,
             "node_count" => 0,
             "primary_shard_count" => 0,
             "primary_shard_size_avg_bytes" => 0,
             "primary_shard_size_mad_bytes" => 0,
             "primary_shard_size_median_bytes" => 0,
             "primary_size_bytes" => 0,
             "total_shard_count" => 0,
             "total_size_bytes" => 0
           },
           "data_warm" => %{
             "doc_count" => 0,
             "index_count" => 0,
             "node_count" => 0,
             "primary_shard_count" => 0,
             "primary_shard_size_avg_bytes" => 0,
             "primary_shard_size_mad_bytes" => 0,
             "primary_shard_size_median_bytes" => 0,
             "primary_size_bytes" => 0,
             "total_shard_count" => 0,
             "total_size_bytes" => 0
           },
           "enabled" => true
         },
         "enterprise_search" => %{
           "analytics_collections" => %{"count" => 0},
           "available" => true,
           "enabled" => true,
           "query_rulesets" => %{
             "max_rule_count" => 0,
             "min_rule_count" => 0,
             "total_count" => 0,
             "total_rule_count" => 0
           },
           "search_applications" => %{"count" => 0}
         },
         "eql" => %{"available" => true, "enabled" => true},
         "esql" => %{
           "available" => true,
           "enabled" => true,
           "features" => %{
             "dissect" => 0,
             "drop" => 0,
             "enrich" => 0,
             "eval" => 0,
             "from" => 0,
             "grok" => 0,
             "keep" => 0,
             "limit" => 0,
             "mv_expand" => 0,
             "rename" => 0,
             "row" => 0,
             "show" => 0,
             "sort" => 0,
             "stats" => 0,
             "where" => 0
           },
           "queries" => %{
             "_all" => %{"failed" => 0, "total" => 0},
             "kibana" => %{"failed" => 0, "total" => 0},
             "rest" => %{"failed" => 0, "total" => 0}
           }
         },
         "frozen_indices" => %{
           "available" => true,
           "enabled" => true,
           "indices_count" => 0
         },
         "graph" => %{"available" => true, "enabled" => true},
         "health_api" => %{
           "available" => true,
           "enabled" => true,
           "invocations" => %{"total" => 0}
         },
         "ilm" => %{"policy_count" => 3, "policy_stats" => []},
         "inference" => %{"available" => true, "enabled" => true, "models" => []},
         "logstash" => %{"available" => true, "enabled" => true},
         "ml" => %{
           "available" => true,
           "data_frame_analytics_jobs" => %{
             "_all" => %{"count" => 0},
             "analysis_counts" => %{},
             "memory_usage" => %{
               "peak_usage_bytes" => %{
                 "avg" => 0.0,
                 "max" => 0.0,
                 "min" => 0.0,
                 "total" => 0.0
               }
             }
           },
           "datafeeds" => %{"_all" => %{"count" => 0}},
           "enabled" => true,
           "inference" => %{
             "deployments" => %{
               "count" => 0,
               "inference_counts" => %{
                 "avg" => 0.0,
                 "max" => 0.0,
                 "min" => 0.0,
                 "total" => 0.0
               },
               "model_sizes_bytes" => %{
                 "avg" => 0.0,
                 "max" => 0.0,
                 "min" => 0.0,
                 "total" => 0.0
               },
               "stats_by_model" => [],
               "time_ms" => %{"avg" => 0.0}
             },
             "ingest_processors" => %{
               "_all" => %{
                 "num_docs_processed" => %{"max" => 0, "min" => 0, "sum" => 0},
                 "num_failures" => %{"max" => 0, "min" => 0, "sum" => 0},
                 "pipelines" => %{"count" => 0},
                 "time_ms" => %{"max" => 0, "min" => 0, "sum" => 0}
               }
             },
             "trained_models" => %{
               "_all" => %{"count" => 1},
               "count" => %{"other" => 0, "prepackaged" => 1, "total" => 1},
               "estimated_operations" => %{
                 "avg" => 0.0,
                 "max" => 0.0,
                 "min" => 0.0,
                 "total" => 0.0
               },
               "model_size_bytes" => %{
                 "avg" => 0.0,
                 "max" => 0.0,
                 "min" => 0.0,
                 "total" => 0.0
               }
             }
           },
           "jobs" => %{
             "_all" => %{
               "count" => 0,
               "created_by" => %{},
               "detectors" => %{},
               "forecasts" => %{"forecasted_jobs" => 0, "total" => 0},
               "model_size" => %{}
             }
           },
           "node_count" => 1
         },
         "monitoring" => %{
           "available" => true,
           "collection_enabled" => false,
           "enabled" => true,
           "enabled_exporters" => %{"local" => 1}
         },
         "remote_clusters" => %{
           "mode" => %{"proxy" => 0, "sniff" => 0},
           "security" => %{"api_key" => 0, "cert" => 0},
           "size" => 0
         },
         "rollup" => %{"available" => true, "enabled" => true},
         "searchable_snapshots" => %{
           "available" => true,
           "enabled" => true,
           "full_copy_indices_count" => 0,
           "indices_count" => 0,
           "shared_cache_indices_count" => 0
         },
         "security" => %{"available" => true, "enabled" => true},
         "slm" => %{"available" => true, "enabled" => true},
         "spatial" => %{"available" => true, "enabled" => true},
         "sql" => %{
           "available" => true,
           "enabled" => true,
           "features" => %{
             "command" => 0,
             "groupby" => 0,
             "having" => 0,
             "join" => 0,
             "limit" => 0,
             "local" => 0,
             "orderby" => 0,
             "subselect" => 0,
             "where" => 0
           },
           "queries" => %{
             "_all" => %{"failed" => 0, "paging" => 0, "total" => 0},
             "canvas" => %{"failed" => 0, "paging" => 0, "total" => 0},
             "cli" => %{"failed" => 0, "paging" => 0, "total" => 0},
             "jdbc" => %{"failed" => 0, "paging" => 0, "total" => 0},
             "odbc" => %{"failed" => 0, "paging" => 0, "total" => 0},
             "odbc32" => %{"failed" => 0, "paging" => 0, "total" => 0},
             "odbc64" => %{"failed" => 0, "paging" => 0, "total" => 0},
             "rest" => %{"failed" => 0, "paging" => 0, "total" => 0},
             "translate" => %{"count" => 0}
           }
         },
         "transform" => %{"available" => true, "enabled" => true},
         "universal_profiling" => %{"available" => true, "enabled" => true},
         "voting_only" => %{"available" => true, "enabled" => true},
         "watcher" => %{
           "available" => true,
           "count" => %{"active" => 0, "total" => 0},
           "enabled" => true,
           "execution" => %{
             "actions" => %{"_all" => %{"total" => 0, "total_time_in_ms" => 0}}
           },
           "watch" => %{
             "input" => %{"_all" => %{"active" => 0, "total" => 0}},
             "trigger" => %{"_all" => %{"active" => 0, "total" => 0}}
           }
         }
       }}
  """
  @doc since: "1.2.0"
  @spec xpack(opts()) :: ElasticsearchEx.response()
  def xpack(opts \\ []) when is_list(opts) do
    Client.get("/_xpack/usage", nil, nil, opts)
  end
end
