defmodule ElasticsearchEx.Api.CatTest do
  use ElasticsearchEx.ConnCase

  alias ElasticsearchEx.Api.Cat

  ## Tests

  describe "aliases/2" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.aliases(nil, format: :json, v: true)
      assert is_list(response)
    end
  end

  describe "allocation/2" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.allocation(nil, format: :json, v: true)
      assert is_list(response)
    end
  end

  describe "anomaly_detectors/2" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.anomaly_detectors(nil, format: :json, v: true)
      assert is_list(response)
    end
  end

  describe "component_templates/2" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.component_templates(nil, format: :json, v: true)
      assert is_list(response)
    end
  end

  describe "count/2" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.count(nil, format: :json, v: true)
      assert is_list(response)
    end
  end

  describe "data_frame_analytics/2" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.data_frame_analytics(nil, format: :json, v: true)
      assert is_list(response)
    end
  end

  describe "datafeeds/2" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.datafeeds(nil, format: :json, v: true)
      assert is_list(response)
    end
  end

  describe "fielddata/2" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.fielddata(nil, format: :json, v: true)
      assert is_list(response)
    end
  end

  describe "health/2" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.health(nil, format: :json, v: true)
      assert is_list(response)
    end
  end

  describe "indices/2" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.indices(nil, format: :json, v: true)
      assert is_list(response)
    end
  end

  describe "master/1" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.master(format: :json, v: true)
      assert is_list(response)
    end
  end

  describe "nodeattrs/1" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.nodeattrs(format: :json, v: true)
      assert is_list(response)
    end
  end

  describe "nodes/1" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.nodes(format: :json, v: true)
      assert is_list(response)
    end
  end

  describe "pending_tasks/1" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.pending_tasks(format: :json, v: true)
      assert is_list(response)
    end
  end

  describe "plugins/1" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.plugins(format: :json, v: true)
      assert is_list(response)
    end
  end

  describe "recovery/2" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.recovery(nil, format: :json, v: true)
      assert is_list(response)
    end
  end

  describe "repositories/1" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.repositories(format: :json, v: true)
      assert is_list(response)
    end
  end

  describe "segments/2" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.segments(nil, format: :json, v: true)
      assert is_list(response)
    end
  end

  describe "shards/2" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.shards(nil, format: :json, v: true)
      assert is_list(response)
    end
  end

  describe "snapshots/2" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.snapshots(nil, format: :json, v: true)
      assert is_list(response)
    end
  end

  describe "tasks/1" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.tasks(format: :json, v: true)
      assert is_list(response)
    end
  end

  describe "templates/2" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.templates(nil, format: :json, v: true)
      assert is_list(response)
    end
  end

  describe "thread_pool/2" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.thread_pool(nil, format: :json, v: true)
      assert is_list(response)
    end
  end

  describe "trained_models/1" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.trained_models(format: :json, v: true)
      assert is_list(response)
    end
  end

  describe "transforms/2" do
    test "returns a successful response" do
      assert {:ok, response} = Cat.transforms(nil, format: :json, v: true)
      assert is_list(response)
    end
  end
end
