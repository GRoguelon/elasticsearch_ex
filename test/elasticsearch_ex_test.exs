defmodule ElasticsearchExTest do
  use ExUnit.Case, async: true

  describe "search/2" do
    test "exposes a function of arity of 2" do
      assert {:search, 2} in ElasticsearchEx.__info__(:functions)
    end
  end

  describe "index/2" do
    test "exposes a function of arity of 2" do
      assert {:index, 2} in ElasticsearchEx.__info__(:functions)
    end
  end
end
