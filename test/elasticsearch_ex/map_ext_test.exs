defmodule ElasticsearchEx.MapExtTest do
  use ExUnit.Case, async: true

  ## Tests

  describe "atomize_keys/1" do
    import ElasticsearchEx.MapExt, only: [atomize_keys: 1]

    test "converts string keys to atoms in a flat map" do
      assert atomize_keys(%{"a" => :a, "b" => :b}) == %{a: :a, b: :b}
    end

    test "converts string keys to atoms in nested maps" do
      assert atomize_keys(%{"a" => :a, "b" => %{"c" => %{"d" => :d}}}) ==
               %{a: :a, b: %{c: %{d: :d}}}
    end

    test "converts string keys to atoms in maps within lists" do
      assert atomize_keys(%{"a" => :a, "b" => [%{"c" => :c}, %{"d" => :d}]}) ==
               %{a: :a, b: [%{c: :c}, %{d: :d}]}
    end

    test "preserves atom keys" do
      assert atomize_keys(%{"a" => :a, b: %{"c" => :c}}) ==
               %{a: :a, b: %{c: :c}}
    end

    test "handles empty map" do
      assert atomize_keys(%{}) == %{}
    end

    test "preserves non-map/non-list values" do
      assert atomize_keys(%{"a" => 1, "b" => :atom, "c" => {1, 2}}) ==
               %{a: 1, b: :atom, c: {1, 2}}
    end

    test "handles nested lists" do
      assert atomize_keys(%{"a" => [[%{"b" => :b}]]}) ==
               %{a: [[%{b: :b}]]}
    end

    test "handles complex nested structures" do
      input = %{
        "a" => :a,
        "b" => [%{"c" => %{"d" => :d}}, %{"e" => [1, %{"f" => :f}]}]
      }

      expected = %{
        a: :a,
        b: [%{c: %{d: :d}}, %{e: [1, %{f: :f}]}]
      }

      assert atomize_keys(input) == expected
    end

    test "preserves structs" do
      date = DateTime.utc_now()
      assert atomize_keys(%{"a" => date}) == %{a: date}
    end

    test "handles edge case keys" do
      assert atomize_keys(%{"" => :empty, "key with space" => :space}) ==
               %{:"" => :empty, :"key with space" => :space}
    end

    test "raises FunctionClauseError for non-map input" do
      assert_raise FunctionClauseError, fn -> atomize_keys(a: 1) end
      assert_raise FunctionClauseError, fn -> atomize_keys(:atom) end
      assert_raise FunctionClauseError, fn -> atomize_keys(123) end
    end
  end
end
