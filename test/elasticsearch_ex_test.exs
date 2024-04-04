defmodule ElasticsearchExTest do
  use ExUnit.Case, async: true

  describe "search" do
    test "exposes a function of arity of 0" do
      assert {:search, 0} in ElasticsearchEx.__info__(:functions)
    end

    test "exposes a function of arity of 1" do
      assert {:search, 1} in ElasticsearchEx.__info__(:functions)
    end

    test "exposes a function of arity of 2" do
      assert {:search, 2} in ElasticsearchEx.__info__(:functions)
    end

    test "exposes a function of arity of 3" do
      assert {:search, 3} in ElasticsearchEx.__info__(:functions)
    end
  end

  describe "index/4" do
    test "exposes a function of arity of 4" do
      assert {:index, 4} in ElasticsearchEx.__info__(:functions)
    end
  end

  describe "stream/3" do
    test "exposes a function of arity of 3" do
      assert {:stream, 3} in ElasticsearchEx.__info__(:functions)
    end
  end
end
