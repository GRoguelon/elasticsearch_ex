defmodule ElasticsearchExTest do
  use ExUnit.Case, async: true

  describe "search/2" do
    test "exposes a function of arity of 2" do
      assert function_exported?(ElasticsearchEx, :search, 2)
    end
  end
end
