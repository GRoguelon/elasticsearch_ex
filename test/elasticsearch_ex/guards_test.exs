defmodule ElasticsearchEx.GuardsTest do
  use ExUnit.Case, async: true

  import ElasticsearchEx.Guards

  describe "is_index/1" do
    test "with nil" do
      refute is_index(nil)
    end

    test "with an atom" do
      assert is_index(:index)
    end

    test "with a string" do
      assert is_index("index")
    end

    test "with an empty string" do
      refute is_index("")
    end
  end

  describe "is_document_id/1" do
    test "with nil" do
      refute is_document_id(nil)
    end

    test "with an atom" do
      refute is_document_id(:doc_id)
    end

    test "with a string" do
      assert is_document_id("doc_id")
    end

    test "with an empty string" do
      refute is_document_id("")
    end
  end

  describe "is_enum/1" do
    test "with list" do
      assert is_enum([])
    end

    test "with a Stream" do
      stream = Stream.map([], & &1)

      assert is_enum(stream)
    end

    test "with a map" do
      refute is_enum(%{})
    end

    test "with nil" do
      refute is_enum(nil)
    end
  end

  describe "is_identifier/1" do
    test "with nil" do
      refute is_identifier(nil)
    end

    test "with an atom" do
      assert is_identifier(:doc_id)
    end

    test "with a string" do
      assert is_identifier("doc_id")
    end

    test "with an empty string" do
      refute is_identifier("")
    end
  end
end
