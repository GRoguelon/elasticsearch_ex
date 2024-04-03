defmodule ElasticsearchEx.Api.Cat do
  @moduledoc """
  Provides the functions to interact with the CAT APIs.

  > #### Important {: .warning}
  >
  > `cat` APIs are only intended for human consumption using the command line or Kibana console.
  > They are not intended for use by applications. For application consumption, use the index
  > segments API.
  """

  import ElasticsearchEx.Utils, only: [generate_path: 1]

  alias ElasticsearchEx.Client

  ## Typespecs

  @type index :: ElasticsearchEx.index()

  @type opts :: ElasticsearchEx.opts()

  ## Public functions

  @doc """
  Retrieves the cluster’s index aliases, including filter and routing information. The API does not
  return data stream aliases.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/cat-alias.html#cat-alias-api-query-params)
  for a detailed list of the parameters.

  ### Examples

      iex> ElasticsearchEx.Api.Cat.aliases(nil, format: :json, v: true)
      {:ok,
       [
         %{
           "alias" => "my-alias",
           "filter" => "-",
           "index" => "my-index",
           "is_write_index" => "-",
           "routing.index" => "-",
           "routing.search" => "-"
         }
       ]}
  """
  @doc since: "1.1.0"
  @spec aliases(nil | index(), opts()) :: ElasticsearchEx.response()
  def aliases(index \\ nil, opts \\ []) do
    path = generate_path([:"_cat/aliases", index])

    Client.get(path, nil, nil, opts)
  end

  @doc """
  Provides a snapshot of the number of shards allocated to each data node and their disk space.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/cat-allocation.html#cat-allocation-api-query-params)
  for a detailed list of the parameters.

  ### Examples

      iex> ElasticsearchEx.Api.Cat.allocation(nil, format: :json, v: true)
      {:ok,
       [
         %{
           "disk.avail" => "35.3gb",
           "disk.indices" => "23.8kb",
           "disk.percent" => "84",
           "disk.total" => "228.2gb",
           "disk.used" => "192.8gb",
           "host" => "127.0.0.1",
           "ip" => "127.0.0.1",
           "node" => "my-node",
           "node.role" => "cdfhilmrstw",
           "shards" => "3"
         }
       ]}
  """
  @doc since: "1.1.0"
  @spec allocation(nil | binary(), opts()) :: ElasticsearchEx.response()
  def allocation(node_id \\ nil, opts \\ []) do
    path = generate_path([:"_cat/allocation", node_id])

    Client.get(path, nil, nil, opts)
  end

  @doc """
  Returns configuration and usage information about anomaly detection jobs.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/cat-anomaly-detectors.html#cat-anomaly-detectors-query-params)
  for a detailed list of the parameters.

  ### Examples

      iex> ElasticsearchEx.Api.Cat.anomaly_detectors(nil, format: :json, h: "id,s,dpr,mb", v: true)
      {:ok,
       [
         %{
           "dpr" => "14022",
           "id" => "high_sum_total_sales",
           "mb" => "1.5mb",
           "s" => "closed"
         },
         %{
           "dpr" => "1216",
           "id" => "low_request_rate",
           "mb" => "40.5kb",
           "s" => "closed"
         },
         %{
           "dpr" => "28146",
           "id" => "response_code_rates",
           "mb" => "132.7kb",
           "s" => "closed"
         },
         %{
           "dpr" => "28146",
           "id" => "url_scanning",
           "mb" => "501.6kb",
           "s" => "closed"
         }
       ]}
  """
  @doc since: "1.1.0"
  @spec anomaly_detectors(nil | index(), opts()) :: ElasticsearchEx.response()
  def anomaly_detectors(index \\ nil, opts \\ []) do
    path = generate_path([:"_cat/ml/anomaly_detectors", index])

    Client.get(path, nil, nil, opts)
  end

  @doc """
  Returns information about component templates in a cluster. Component templates are building
  blocks for constructing index templates that specify index mappings, settings, and aliases.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/cat-component-templates.html#cat-component-templates-query-params)
  for a detailed list of the parameters.

  ### Examples

      iex> ElasticsearchEx.Api.Cat.component_templates(nil, format: :json, s: "name", v: true)
      {:ok,
       [
         %{
           "alias_count" => "0",
           "included_in" => "[my-index-template]",
           "mapping_count" => "1",
           "name" => "my-template-1",
           "settings_count" => "0",
           "version" => "0"
         },
         %{
           "alias_count" => "3",
           "included_in" => "[my-index-template]",
           "mapping_count" => "0",
           "name" => "my-template-2",
           "settings_count" => "0",
           "version" => "0"
         }
       ]}
  """
  @doc since: "1.1.0"
  @spec component_templates(nil | index(), opts()) :: ElasticsearchEx.response()
  def component_templates(index \\ nil, opts \\ []) do
    path = generate_path([:"_cat/component_templates", index])

    Client.get(path, nil, nil, opts)
  end

  @doc """
  Provides quick access to a document count for a data stream, an index, or an entire cluster.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/cat-count.html#cat-count-api-query-params)
  for a detailed list of the parameters.

  ### Examples

      iex> ElasticsearchEx.Api.Cat.count(nil, format: :json, v: true)
      {:ok, [%{"count" => "4", "epoch" => "1712153041", "timestamp" => "14:04:01"}]}
  """
  @doc since: "1.1.0"
  @spec count(nil | index(), opts()) :: ElasticsearchEx.response()
  def count(index \\ nil, opts \\ []) do
    path = generate_path([:"_cat/count", index])

    Client.get(path, nil, nil, opts)
  end

  @doc """
  Returns configuration and usage information about data frame analytics jobs.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/cat-dfanalytics.html#cat-dfanalytics-query-params)
  for a detailed list of the parameters.

  ### Examples

      iex> ElasticsearchEx.Api.Cat.data_frame_analytics(nil, format: :json, v: true)
      {:ok,
       [
         %{
           "create_time" => "2020-02-12T11:49:09.594Z",
           "id" => "classifier_job_1",
           "state" => "stopped",
           "type" => "classification"
         },
         %{
           "create_time" => "2020-02-12T11:49:14.479Z",
           "id" => "classifier_job_2",
           "state" => "stopped",
           "type" => "classification"
         },
         %{
           "create_time" => "2020-02-12T11:49:16.928Z",
           "id" => "classifier_job_3",
           "state" => "stopped",
           "type" => "classification"
         },
         %{
           "create_time" => "2020-02-12T11:49:19.127Z",
           "id" => "classifier_job_4",
           "state" => "stopped",
           "type" => "classification"
         },
         %{
           "create_time" => "2020-02-12T11:49:21.349Z",
           "id" => "classifier_job_5",
           "state" => "stopped",
           "type" => "classification"
         }
       ]}
  """
  @doc since: "1.1.0"
  @spec data_frame_analytics(nil | binary(), opts()) :: ElasticsearchEx.response()
  def data_frame_analytics(data_frame_analytics_id \\ nil, opts \\ []) do
    path = generate_path([:"_cat/ml/data_frame/analytics", data_frame_analytics_id])

    Client.get(path, nil, nil, opts)
  end

  @doc """
  Returns configuration and usage information about datafeeds.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/cat-datafeeds.html#cat-datafeeds-query-params)
  for a detailed list of the parameters.

  ### Examples

      iex> ElasticsearchEx.Api.Cat.datafeeds(nil, format: :json, v: true)
      {:ok,
       [
         %{
           "buckets.count" => "743",
           "id" => "datafeed-high_sum_total_sales",
           "search.count" => "7",
           "state" => "stopped"
         },
         %{
           "buckets.count" => "1457",
           "id" => "datafeed-low_request_rate",
           "search.count" => "3",
           "state" => "stopped"
         },
         %{
           "buckets.count" => "1460",
           "id" => "datafeed-response_code_rates",
           "search.count" => "18",
           "state" => "stopped"
         },
         %{
           "buckets.count" => "1460",
           "id" => "datafeed-url_scanning",
           "search.count" => "18",
           "state" => "stopped"
         }
       ]}
  """
  @doc since: "1.1.0"
  @spec datafeeds(nil | binary(), opts()) :: ElasticsearchEx.response()
  def datafeeds(feed_id \\ nil, opts \\ []) do
    path = generate_path([:"_cat/ml/datafeeds", feed_id])

    Client.get(path, nil, nil, opts)
  end

  @doc """
  Returns the amount of heap memory currently used by the field data cache on every data node in the cluster.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/cat-fielddata.html#cat-fielddata-api-query-params)
  for a detailed list of the parameters.

  ### Examples

      iex> ElasticsearchEx.Api.Cat.fielddata(nil, format: :json, v: true)
      {:ok,
       [
         %{
           "field" => "body",
           "host" => "127.0.0.1",
           "id" => "Nqk-6inXQq-OxUfOUI8jNQ",
           "ip" => "127.0.0.1",
           "node" => "Nqk-6in",
           "size" => "544b"
         },
         %{
           "field" => "mind",
           "host" => "127.0.0.1",
           "id" => "Nqk-6inXQq-OxUfOUI8jNQ",
           "ip" => "127.0.0.1",
           "node" => "Nqk-6in",
           "size" => "360b"
         },
         %{
           "field" => "soul",
           "host" => "127.0.0.1",
           "id" => "Nqk-6inXQq-OxUfOUI8jNQ",
           "ip" => "127.0.0.1",
           "node" => "Nqk-6in",
           "size" => "480b"
         }
       ]}
  """
  @doc since: "1.1.0"
  @spec fielddata(nil | binary(), opts()) :: ElasticsearchEx.response()
  def fielddata(field \\ nil, opts \\ []) do
    path = generate_path([:"_cat/fielddata", field])

    Client.get(path, nil, nil, opts)
  end

  @doc """
  Returns the health status of a cluster, similar to the cluster health API.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/cat-health.html#cat-health-api-query-params)
  for a detailed list of the parameters.

  ### Examples

      iex> ElasticsearchEx.Api.Cat.health(nil, format: :json, v: true)
      {:ok,
       [
         %{
           "active_shards_percent" => "100.0%",
           "cluster" => "elasticsearch",
           "epoch" => "1712153802",
           "init" => "0",
           "max_task_wait_time" => "-",
           "node.data" => "1",
           "node.total" => "1",
           "pending_tasks" => "0",
           "pri" => "3",
           "relo" => "0",
           "shards" => "3",
           "status" => "green",
           "timestamp" => "14:16:42",
           "unassign" => "0"
         }
       ]}
  """
  @doc since: "1.1.0"
  @spec health(nil | index(), opts()) :: ElasticsearchEx.response()
  def health(index \\ nil, opts \\ []) do
    path = generate_path([:"_cat/health", index])

    Client.get(path, nil, nil, opts)
  end

  @doc """
  Returns high-level information about indices in a cluster, including backing indices for data streams.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/cat-indices.html#cat-indices-api-query-params)
  for a detailed list of the parameters.

  ### Examples

      iex> ElasticsearchEx.Api.Cat.indices(nil,
      ...>   format: :json,
      ...>   include_unloaded_segments: true,
      ...>   v: true,
      ...>   h: "index,pri,rep,health,status,docs.count,docs.deleted,store.size,pri.store.size",
      ...>   s: :index
      ...> )
      {:ok,
       [
         %{
           "docs.count" => "6",
           "docs.deleted" => "0",
           "health" => "green",
           "index" => "my-index",
           "pri" => "1",
           "pri.store.size" => "18.9kb",
           "rep" => "0",
           "status" => "open",
           "store.size" => "18.9kb"
         }
       ]}
  """
  @doc since: "1.1.0"
  @spec indices(nil | index(), opts()) :: ElasticsearchEx.response()
  def indices(index \\ nil, opts \\ []) do
    path = generate_path([:"_cat/indices", index])

    Client.get(path, nil, nil, opts)
  end

  @doc """
  Returns information about the master node, including the ID, bound IP address, and name.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/cat-master.html#cat-master-api-query-params)
  for a detailed list of the parameters.

  ### Examples

      iex> ElasticsearchEx.Api.Cat.master(format: :json, v: true)
      {:ok,
       [
         %{
           "host" => "127.0.0.1",
           "id" => "YzWoH_2BT-6UjVGDyPdqYg",
           "ip" => "127.0.0.1",
           "node" => "YzWoH_2"
         }
       ]}
  """
  @doc since: "1.1.0"
  @spec master(opts()) :: ElasticsearchEx.response()
  def master(opts \\ []) do
    Client.get("/_cat/master", nil, nil, opts)
  end

  @doc """
  Returns information about custom node attributes.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/cat-nodeattrs.html#cat-nodeattrs-api-query-params)
  for a detailed list of the parameters.

  ### Examples

      iex> ElasticsearchEx.Api.Cat.nodeattrs(format: :json, v: true)
      {:ok,
       [
         %{
           "attr" => "testattr",
           "host" => "127.0.0.1",
           "ip" => "127.0.0.1",
           "node" => "node-0",
           "value" => "test"
         }
       ]}
  """
  @doc since: "1.1.0"
  @spec nodeattrs(opts()) :: ElasticsearchEx.response()
  def nodeattrs(opts \\ []) do
    Client.get("/_cat/nodeattrs", nil, nil, opts)
  end

  @doc """
  Returns information about a cluster’s nodes.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/cat-nodes.html#cat-nodes-api-query-params)
  for a detailed list of the parameters.

  ### Examples

      iex> ElasticsearchEx.Api.Cat.nodes(format: :json, v: true)
      {:ok,
       [
         %{
           "cpu" => "42",
           "heap.percent" => "65",
           "ip" => "127.0.0.1",
           "load_15m" => "*",
           "load_1m" => "3.07",
           "load_5m" => "dim",
           "node.role" => "mJw06l1",
           "ram.percent" => "99"
         }
       ]}
  """
  @doc since: "1.1.0"
  @spec nodes(opts()) :: ElasticsearchEx.response()
  def nodes(opts \\ []) do
    Client.get("/_cat/nodes", nil, nil, opts)
  end

  @doc """
  Returns cluster-level changes that have not yet been executed, similar to the pending cluster tasks API.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/cat-pending_tasks.html#cat-pending_tasks-api-query-params)
  for a detailed list of the parameters.

  ### Examples

      iex> ElasticsearchEx.Api.Cat.pending_tasks(format: :json, v: true)
      {:ok,
       [
         %{
           "insertOrder" => "1685",
           "priority" => "HIGH",
           "source" => "update-mapping",
           "timeInQueue" => "855ms"
         },
         %{
           "insertOrder" => "1686",
           "priority" => "HIGH",
           "source" => "update-mapping",
           "timeInQueue" => "843ms"
         },
         %{
           "insertOrder" => "1693",
           "priority" => "HIGH",
           "source" => "update-mapping",
           "timeInQueue" => "753ms"
         },
         %{
           "insertOrder" => "1688",
           "priority" => "HIGH",
           "source" => "update-mapping",
           "timeInQueue" => "816ms"
         },
         %{
           "insertOrder" => "1689",
           "priority" => "HIGH",
           "source" => "update-mapping",
           "timeInQueue" => "802ms"
         },
         %{
           "insertOrder" => "1690",
           "priority" => "HIGH",
           "source" => "update-mapping",
           "timeInQueue" => "787ms"
         },
         %{
           "insertOrder" => "1691",
           "priority" => "HIGH",
           "source" => "update-mapping",
           "timeInQueue" => "773ms"
         }
       ]}
  """
  @doc since: "1.1.0"
  @spec pending_tasks(opts()) :: ElasticsearchEx.response()
  def pending_tasks(opts \\ []) do
    Client.get("/_cat/pending_tasks", nil, nil, opts)
  end

  @doc """
  Returns cluster-level changes that have not yet been executed, similar to the pending cluster tasks API.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/cat-plugins.html#cat-plugins-api-query-params)
  for a detailed list of the parameters.

  ### Examples

      iex> ElasticsearchEx.Api.Cat.plugins(format: :json, h: "name,component,version,description", s: "component", v: true)
      {:ok,
       [
         %{
           "component" => "analysis-icu",
           "description" => "The ICU Analysis plugin integrates the Lucene ICU module into Elasticsearch, adding ICU-related analysis components.",
           "name" => "U7321H6",
           "version" => "8.13.1"
         },
         %{
           "component" => "analysis-kuromoji",
           "description" => "The Japanese (kuromoji) Analysis plugin integrates Lucene kuromoji analysis module into elasticsearch.",
           "name" => "U7321H6",
           "version" => "8.13.1"
         },
         %{
           "component" => "analysis-nori",
           "description" => "The Korean (nori) Analysis plugin integrates Lucene nori analysis module into elasticsearch.",
           "name" => "U7321H6",
           "version" => "8.13.1"
         },
         %{
           "component" => "analysis-phonetic",
           "description" => "The Phonetic Analysis plugin integrates phonetic token filter analysis with elasticsearch.",
           "name" => "U7321H6",
           "version" => "8.13.1"
         },
         %{
           "component" => "analysis-smartcn",
           "description" => "Smart Chinese Analysis plugin integrates Lucene Smart Chinese analysis module into elasticsearch.",
           "name" => "U7321H6",
           "version" => "8.13.1"
         },
         %{
           "component" => "analysis-stempel",
           "description" => "The Stempel (Polish) Analysis plugin integrates Lucene stempel (polish) analysis module into elasticsearch.",
           "name" => "U7321H6",
           "version" => "8.13.1"
         },
         %{
           "component" => "analysis-ukrainian",
           "description" => "The Ukrainian Analysis plugin integrates the Lucene UkrainianMorfologikAnalyzer into elasticsearch.",
           "name" => "U7321H6",
           "version" => "8.13.1"
         },
         %{
           "component" => "discovery-azure-classic",
           "description" => "The Azure Classic Discovery plugin allows to use Azure Classic API for the unicast discovery mechanism",
           "name" => "U7321H6",
           "version" => "8.13.1"
         },
         %{
           "component" => "discovery-ec2",
           "description" => "The EC2 discovery plugin allows to use AWS API for the unicast discovery mechanism.",
           "name" => "U7321H6",
           "version" => "8.13.1"
         },
         %{
           "component" => "discovery-gce",
           "description" => "The Google Compute Engine (GCE) Discovery plugin allows to use GCE API for the unicast discovery mechanism.",
           "name" => "U7321H6",
           "version" => "8.13.1"
         },
         %{
           "component" => "mapper-annotated-text",
           "description" => "The Mapper Annotated_text plugin adds support for text fields with markup used to inject annotation tokens into the index.",
           "name" => "U7321H6",
           "version" => "8.13.1"
         },
         %{
           "component" => "mapper-murmur3",
           "description" => "The Mapper Murmur3 plugin allows to compute hashes of a field's values at index-time and to store them in the index.",
           "name" => "U7321H6",
           "version" => "8.13.1"
         },
         %{
           "component" => "mapper-size",
           "description" => "The Mapper Size plugin allows document to record their uncompressed size at index time.",
           "name" => "U7321H6",
           "version" => "8.13.1"
         },
         %{
           "component" => "store-smb",
           "description" => "The Store SMB plugin adds support for SMB stores.",
           "name" => "U7321H6",
           "version" => "8.13.1"
         }
       ]}
  """
  @doc since: "1.1.0"
  @spec plugins(opts()) :: ElasticsearchEx.response()
  def plugins(opts \\ []) do
    Client.get("/_cat/plugins", nil, nil, opts)
  end

  @doc """
  Returns information about ongoing and completed shard recoveries, similar to the index recovery API.

  For data streams, the API returns information about the stream’s backing indices.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/cat-recovery.html#cat-recovery-api-query-params)
  for a detailed list of the parameters.

  ### Examples

      iex> ElasticsearchEx.Api.Cat.recovery(format: :json, v: true)
      {:ok,
       [
         %{
           "bytes" => "0b",
           "bytes_percent" => "100%",
           "bytes_recovered" => "0b",
           "bytes_total" => "9928b",
           "files" => "0",
           "files_percent" => "100%",
           "files_recovered" => "0",
           "files_total" => "13",
           "index" => "my-index-000001",
           "repository" => "n/a",
           "shard" => "0",
           "snapshot" => "n/a",
           "source_host" => "n/a",
           "source_node" => "n/a",
           "stage" => "done",
           "target_host" => "127.0.0.1",
           "target_node" => "node-0",
           "time" => "13ms",
           "translog_ops" => "0",
           "translog_ops_percent" => "100.0%",
           "translog_ops_recovered" => "0",
           "type" => "store"
         }
       ]}
  """
  @doc since: "1.1.0"
  @spec recovery(nil | index(), opts()) :: ElasticsearchEx.response()
  def recovery(index \\ nil, opts \\ []) do
    path = generate_path([:"_cat/recovery", index])

    Client.get(path, nil, nil, opts)
  end

  @doc """
  Returns the snapshot repositories for a cluster.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/cat-repositories.html#cat-repositories-api-query-params)
  for a detailed list of the parameters.

  ### Examples

      iex> ElasticsearchEx.Api.Cat.repositories(format: :json, v: true)
      {:ok, [%{"id" => "repo1", "type" => "fs"}, %{"id" => "repo2", "type" => "s3"}]}
  """
  @doc since: "1.1.0"
  @spec repositories(opts()) :: ElasticsearchEx.response()
  def repositories(opts \\ []) do
    Client.get("/_cat/repositories", nil, nil, opts)
  end

  @doc """
  Returns low-level information about the Lucene segments in index shards, similar to the indices segments API.

  For data streams, the API returns information about the stream’s backing indices.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/cat-segments.html#cat-segments-api-query-params)
  for a detailed list of the parameters.

  ### Examples

      iex> ElasticsearchEx.Api.Cat.segments(nil, format: :json, v: true)
      {:ok,
       [
         %{
           "committed" => "false",
           "compound" => "true",
           "docs.count" => "1",
           "docs.deleted" => "0",
           "generation" => "0",
           "index" => "test",
           "ip" => "127.0.0.1",
           "prirep" => "p",
           "searchable" => "true",
           "segment" => "_0",
           "shard" => "0",
           "size" => "3kb",
           "size.memory" => "0",
           "version" => "9.10.0"
         },
         %{
           "committed" => "false",
           "compound" => "true",
           "docs.count" => "1",
           "docs.deleted" => "0",
           "generation" => "0",
           "index" => "test1",
           "ip" => "127.0.0.1",
           "prirep" => "p",
           "searchable" => "true",
           "segment" => "_0",
           "shard" => "0",
           "size" => "3kb",
           "size.memory" => "0",
           "version" => "9.10.0"
         }
       ]}
  """
  @doc since: "1.1.0"
  @spec segments(nil | index(), opts()) :: ElasticsearchEx.response()
  def segments(index \\ nil, opts \\ []) do
    path = generate_path([:"_cat/segments", index])

    Client.get(path, nil, nil, opts)
  end

  @doc """
  The shards command is the detailed view of what nodes contain which shards. It will tell you if
  it’s a primary or replica, the number of docs, the bytes it takes on disk, and the node where it’s
  located.

  For data streams, the API returns information about the stream’s backing indices.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/cat-shards.html#cat-shards-api-query-params)
  for a detailed list of the parameters.

  ### Examples

      iex> ElasticsearchEx.Api.Cat.shards(nil, format: :json, v: true)
      {:ok,
       [
         %{
           "dataset" => "18.9kb",
           "docs" => "6",
           "index" => "my-index",
           "ip" => "127.0.0.1",
           "node" => "my-node",
           "prirep" => "p",
           "shard" => "0",
           "state" => "STARTED",
           "store" => "18.9kb"
         }
       ]}
  """
  @doc since: "1.1.0"
  @spec shards(nil | index(), opts()) :: ElasticsearchEx.response()
  def shards(index \\ nil, opts \\ []) do
    path = generate_path([:"_cat/shards", index])

    Client.get(path, nil, nil, opts)
  end

  @doc """
  Returns information about the snapshots stored in one or more repositories. A snapshot is a backup
  of an index or running Elasticsearch cluster.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/cat-snapshots.html#cat-snapshots-api-query-params)
  for a detailed list of the parameters.

  ### Examples

      iex> ElasticsearchEx.Api.Cat.snapshots(nil, format: :json, v: true, s: "id")
      {:ok,
       [
         %{
           "duration" => "4.6m",
           "end_epoch" => "1445616978",
           "end_time" => "18:16:18",
           "failed_shards" => "1",
           "id" => "snap1",
           "indices" => "1",
           "repository" => "repo1",
           "start_epoch" => "1445616705",
           "start_time" => "18:11:45",
           "status" => "FAILED",
           "successful_shards" => "4",
           "total_shards" => "5"
         },
         %{
           "duration" => "6.2m",
           "end_epoch" => "1445634672",
           "end_time" => "23:11:12",
           "failed_shards" => "0",
           "id" => "snap2",
           "indices" => "2",
           "repository" => "repo1",
           "start_epoch" => "1445634298",
           "start_time" => "23:04:58",
           "status" => "SUCCESS",
           "successful_shards" => "10",
           "total_shards" => "10"
         }
       ]}
  """
  @doc since: "1.1.0"
  @spec snapshots(nil | binary(), opts()) :: ElasticsearchEx.response()
  def snapshots(repository \\ nil, opts \\ []) do
    path = generate_path([:"_cat/snapshots", repository])

    Client.get(path, nil, nil, opts)
  end

  @doc """
  Returns information about tasks currently executing in the cluster, similar to the task management
  API.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/cat-tasks.html#cat-tasks-api-query-params)
  for a detailed list of the parameters.

  ### Examples

      iex> ElasticsearchEx.Api.Cat.tasks(format: :json, v: true)
      {:ok,
       [
         %{
           "action" => "cluster:monitor/tasks/lists[n]",
           "ip" => "127.0.0.1:9300",
           "node" => "oTUltX4IQMOUUVeiohTt8A",
           "parent_task_id" => "oTUltX4IQMOUUVeiohTt8A:123",
           "running_time" => "44.1micros",
           "start_time" => "1458585884904",
           "task_id" => "oTUltX4IQMOUUVeiohTt8A:124",
           "timestamp" => "01:48:24",
           "type" => "direct"
         },
         %{
           "action" => "cluster:monitor/tasks/lists",
           "ip" => "127.0.0.1:9300",
           "node" => "oTUltX4IQMOUUVeiohTt8A",
           "parent_task_id" => "-",
           "running_time" => "186.2micros",
           "start_time" => "1458585884904",
           "task_id" => "oTUltX4IQMOUUVeiohTt8A:123",
           "timestamp" => "01:48:24",
           "type" => "transport"
         }
       ]}
  """
  @doc since: "1.1.0"
  @spec tasks(opts()) :: ElasticsearchEx.response()
  def tasks(opts \\ []) do
    Client.get("/_cat/tasks", nil, nil, opts)
  end

  @doc """
  Returns information about index templates in a cluster. You can use index templates to apply index
  settings and field mappings to new indices at creation.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/cat-templates.html#cat-templates-api-query-params)
  for a detailed list of the parameters.

  ### Examples

      iex> ElasticsearchEx.Api.Cat.templates("my-template-*", format: :json, v: true, s: "name")
      {:ok,
       [
         %{
           "index_patterns" => "[te*]",
           "name" => "my-template-0",
           "order" => "500",
           "version" => "[]"
         },
         %{
           "index_patterns" => "[tea*]",
           "name" => "my-template-1",
           "order" => "501",
           "version" => "[]"
         },
         %{
           "composed_of" => "[]",
           "index_patterns" => "[teak*]",
           "name" => "my-template-2",
           "order" => "502",
           "version" => "7"
         }
       ]}
  """
  @doc since: "1.1.0"
  @spec templates(nil | binary(), opts()) :: ElasticsearchEx.response()
  def templates(template_name \\ nil, opts \\ []) do
    path = generate_path([:"_cat/templates", template_name])

    Client.get(path, nil, nil, opts)
  end

  @doc """
  Returns thread pool statistics for each node in a cluster. Returned information includes all built-in
  thread pools and custom thread pools.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/cat-thread-pool.html#cat-thread-pool-api-query-params)
  for a detailed list of the parameters.

  ### Examples

      iex> ElasticsearchEx.Api.Cat.thread_pool(nil, format: :json, v: true, h: "id,name,active,rejected,completed")
      {:ok,
       [
         %{
           "active" => "0",
           "completed" => "70",
           "id" => "0EWUhXeBQtaVGlexUeVwMg",
           "name" => "generic",
           "rejected" => "0"
         }
       ]}
  """
  @doc since: "1.1.0"
  @spec thread_pool(nil | binary(), opts()) :: ElasticsearchEx.response()
  def thread_pool(thread_pool \\ nil, opts \\ []) do
    path = generate_path([:"_cat/thread_pool", thread_pool])

    Client.get(path, nil, nil, opts)
  end

  @doc """
  Returns configuration and usage information about inference trained models.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/cat-trained-model.html#cat-trained-model-query-params)
  for a detailed list of the parameters.

  ### Examples

      iex> ElasticsearchEx.Api.Cat.trained_models(format: :json, v: true, h: "c,o,l,ct,v")
      {:ok,
       [
         %{
           "create_time" => "2020-01-28T12:56:17.138Z",
           "created_by" => "_xpack",
           "id" => "ddddd-1580216177138",
           "license" => "PLATINUM",
           "operations" => "196",
           "version" => "8.0.0"
         },
         %{
           "create_time" => "2020-01-28T12:48:05.537Z",
           "created_by" => "_xpack",
           "id" => "flight-regress-1580215685537",
           "license" => "PLATINUM",
           "operations" => "102",
           "version" => "8.0.0"
         },
         %{
           "create_time" => "2019-12-05T12:28:34.594Z",
           "created_by" => "_xpack",
           "id" => "lang_ident_model_1",
           "license" => "BASIC",
           "operations" => "39629",
           "version" => "7.6.0"
         }
       ]}
  """
  @doc since: "1.1.0"
  @spec trained_models(opts()) :: ElasticsearchEx.response()
  def trained_models(opts \\ []) do
    Client.get("/_cat/ml/trained_models", nil, nil, opts)
  end

  @doc """
  Returns configuration and usage information about transforms.

  ### Query parameters

  Refer to the official [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/cat-transforms.html#cat-transforms-api-query-params)
  for a detailed list of the parameters.

  ### Examples

      iex> ElasticsearchEx.Api.Cat.transforms(nil, format: :json, v: true)
      {:ok,
       [
         {
           "id" : "ecommerce_transform",
           "state" : "started",
           "checkpoint" : "1",
           "documents_processed" : "705",
           "checkpoint_progress" : "100.00",
           "changes_last_detection_time" : null
         }
       ]}
  """
  @doc since: "1.1.0"
  @spec transforms(nil | binary(), opts()) :: ElasticsearchEx.response()
  def transforms(transform_id \\ nil, opts \\ []) do
    path = generate_path([:"_cat/transforms", transform_id])

    Client.get(path, nil, nil, opts)
  end
end
