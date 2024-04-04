defmodule ElasticsearchEx.GuardsTest do
  use ExUnit.Case, async: true

  import ElasticsearchEx.Guards

  test "is_name/1" do
    assert is_name(nil)
    assert is_name(:index)
    assert is_name("index")
    refute is_name("")
    refute is_name([])
    refute is_name(%{})
    refute is_name({})
    refute is_name(%Stream{})
  end

  test "is_name!/1" do
    refute is_name!(nil)
    assert is_name!(:index)
    assert is_name!("index")
    refute is_name!("")
    refute is_name!([])
    refute is_name!(%{})
    refute is_name!({})
    refute is_name!(%Stream{})
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
