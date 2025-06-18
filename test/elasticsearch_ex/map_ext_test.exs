defmodule ElasticsearchEx.MapExtTest do
  use ExUnit.Case, async: true

  alias ElasticsearchEx.MapExt

  ## Tests

  describe "map_keys/2" do
    test "returns the map unchanged if key_mapper is nil" do
      assert MapExt.map_keys(%{"a" => 1, "b" => 2}, nil) == %{"a" => 1, "b" => 2}
    end

    test "maps string keys to atoms in a flat map" do
      assert MapExt.map_keys(%{"a" => 1, "b" => 2}, &String.to_atom/1) == %{a: 1, b: 2}
    end

    test "maps string keys to uppercase in a flat map" do
      assert MapExt.map_keys(%{"foo" => 1, "bar" => 2}, &String.upcase/1) == %{
               "FOO" => 1,
               "BAR" => 2
             }
    end

    test "maps keys recursively in nested maps" do
      input = %{"a" => %{"b" => %{"c" => 1}}, "d" => 2}
      expected = %{a: %{b: %{c: 1}}, d: 2}
      assert MapExt.map_keys(input, &String.to_atom/1) == expected
    end

    test "maps keys in maps inside lists" do
      input = %{"a" => [%{"b" => 1}, %{"c" => 2}]}
      expected = %{a: [%{b: 1}, %{c: 2}]}
      assert MapExt.map_keys(input, &String.to_atom/1) == expected
    end

    test "preserves atom keys and only maps string keys" do
      input = %{"a" => 1, b: 2}
      expected = %{a: 1, b: 2}
      assert MapExt.map_keys(input, &String.to_atom/1) == expected
    end

    test "handles empty map" do
      assert MapExt.map_keys(%{}, &String.to_atom/1) == %{}
    end

    test "preserves non-map, non-list values" do
      input = %{"a" => 1, "b" => :atom, "c" => {1, 2}}
      expected = %{a: 1, b: :atom, c: {1, 2}}
      assert MapExt.map_keys(input, &String.to_atom/1) == expected
    end

    test "handles nested lists" do
      input = %{"a" => [[%{"b" => 1}]]}
      expected = %{a: [[%{b: 1}]]}
      assert MapExt.map_keys(input, &String.to_atom/1) == expected
    end

    test "preserves structs" do
      date = DateTime.utc_now()
      assert MapExt.map_keys(%{"a" => date}, &String.to_atom/1) == %{a: date}
    end

    test "handles edge case keys" do
      input = %{"key with space" => 1, "" => 2}
      expected = %{"key with space" => 1, "" => 2}
      assert MapExt.map_keys(input, &Function.identity/1) == expected
    end
  end
end
