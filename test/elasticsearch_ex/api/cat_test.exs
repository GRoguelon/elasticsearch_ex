defmodule ElasticsearchEx.API.CatTest do
  use ElasticsearchEx.ConnCase

  alias ElasticsearchEx.API.Cat

  ## Module attributes

  @moduletag :elasticsearch

  @default_settings %{"index.number_of_shards": 1, "index.number_of_replicas": 0}

  ## Tests

  describe "aliases/2" do
    setup(do: setup_aliases())

    @json_alias %{"alias" => "my-alias", "index" => "my-index", "is_write_index" => "true"}

    test "returns information with no arguments" do
      assert {:ok, [@json_alias]} = Cat.aliases()
    end

    test "returns no values if inexistant alias" do
      assert {:ok, []} = Cat.aliases("fake-alias")
    end

    test "returns alias information" do
      assert {:ok, [@json_alias]} = Cat.aliases("my-alias")
    end

    test "returns alias information with options" do
      assert {:ok, response} =
               Cat.aliases(format: :text, v: true, s: "alias,index,is_write_index")

      assert response ==
               "alias    index    filter routing.index routing.search is_write_index\nmy-alias my-index -      -             -              true\n"
    end
  end

  describe "allocation/2" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.allocation(nil, v: true)
      assert is_list(response)
    end
  end

  describe "anomaly_detectors/2" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.anomaly_detectors(nil, v: true)
      assert is_list(response)
    end
  end

  describe "component_templates/2" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.component_templates(nil, v: true)
      assert is_list(response)
    end
  end

  describe "count/2" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.count(nil, v: true)
      assert is_list(response)
    end
  end

  describe "data_frame_analytics/2" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.data_frame_analytics(nil, v: true)
      assert is_list(response)
    end
  end

  describe "datafeeds/2" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.datafeeds(nil, v: true)
      assert is_list(response)
    end
  end

  describe "fielddata/2" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.fielddata(nil, v: true)
      assert is_list(response)
    end
  end

  describe "health/2" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.health(nil, v: true)
      assert is_list(response)
    end
  end

  describe "indices/2" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.indices(nil, v: true)
      assert is_list(response)
    end
  end

  describe "master/1" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.master(v: true)
      assert is_list(response)
    end
  end

  describe "nodeattrs/1" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.nodeattrs(v: true)
      assert is_list(response)
    end
  end

  describe "nodes/1" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.nodes(v: true)
      assert is_list(response)
    end
  end

  describe "pending_tasks/1" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.pending_tasks(v: true)
      assert is_list(response)
    end
  end

  describe "plugins/1" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.plugins(v: true)
      assert is_list(response)
    end
  end

  describe "recovery/2" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.recovery(nil, v: true)
      assert is_list(response)
    end
  end

  describe "repositories/1" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.repositories(v: true)
      assert is_list(response)
    end
  end

  describe "segments/2" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.segments(nil, v: true)
      assert is_list(response)
    end
  end

  describe "shards/2" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.shards(nil, v: true)
      assert is_list(response)
    end
  end

  describe "snapshots/2" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.snapshots(nil, v: true)
      assert is_list(response)
    end
  end

  describe "tasks/1" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.tasks(v: true)
      assert is_list(response)
    end
  end

  describe "templates/2" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.templates(nil, v: true)
      assert is_list(response)
    end
  end

  describe "thread_pool/2" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.thread_pool(nil, v: true)
      assert is_list(response)
    end
  end

  describe "trained_models/1" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.trained_models(v: true)
      assert is_list(response)
    end
  end

  describe "transforms/2" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.transforms(nil, v: true)
      assert is_list(response)
    end
  end

  ## Private functions

  defp setup_aliases do
    ElasticsearchEx.Client.request(:put, "my-index", %{
      aliases: %{"my-alias": %{is_write_index: true}},
      settings: @default_settings
    })

    on_exit(fn -> ElasticsearchEx.Client.request(:delete, "my-index") end)
  end
end
