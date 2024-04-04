defmodule ElasticsearchEx.GuardsTest do
  use ExUnit.Case, async: true

  import ElasticsearchEx.Guards

  test "is_index_or_nil/1" do
    assert is_index_or_nil(nil)
    assert is_index_or_nil(:index)
    assert is_index_or_nil("index")
    refute is_index_or_nil("")
    refute is_index_or_nil([])
    refute is_index_or_nil(%{})
    refute is_index_or_nil({})
    refute is_index_or_nil(%Stream{})
  end

  test "is_index/1" do
    refute is_index(nil)
    assert is_index(:index)
    assert is_index("index")
    refute is_index("")
    refute is_index([])
    refute is_index(%{})
    refute is_index({})
    refute is_index(%Stream{})
  end

  test "is_identifier/1" do
    refute is_identifier(nil)
    refute is_identifier(:doc_id)
    assert is_identifier("doc_id")
    refute is_identifier("")
    refute is_identifier([])
    refute is_identifier(%{})
    refute is_identifier({})
    refute is_identifier(%Stream{})
  end

  test "is_enum/1" do
    assert is_enum([])
    assert is_enum(%Stream{})
    refute is_enum(nil)
    refute is_enum(:atom)
    refute is_enum("string")
    refute is_enum(%{})
    refute is_enum({})
  end
end
