defmodule ElasticsearchEx.DocumentTest do
  use ExUnit.Case, async: true

  alias ElasticsearchEx.Document

  describe "new/1 with a map" do
    test "returns a struct with a map of atoms as key" do
      attrs = %{
        _id: "rvO6H4wBhbFpuyekVIiV",
        _index: "residents-v20240223013056",
        _primary_term: 1,
        _score: 1.0,
        _seq_no: 26_776,
        _source: %{"hello" => "world"},
        _version: 1
      }

      assert %Document{
               _id: "rvO6H4wBhbFpuyekVIiV",
               _index: "residents-v20240223013056",
               _primary_term: 1,
               _score: 1.0,
               _seq_no: 26_776,
               _source: %{"hello" => "world"},
               _version: 1
             } = Document.new(attrs)
    end

    test "returns a struct with a map of atoms as binary" do
      attrs = %{
        "_id" => "rvO6H4wBhbFpuyekVIiV",
        "_index" => "residents-v20240223013056",
        "_primary_term" => 1,
        "_score" => 1.0,
        "_seq_no" => 26_776,
        "_source" => %{"hello" => "world"},
        "_version" => 1
      }

      assert %Document{
               _id: "rvO6H4wBhbFpuyekVIiV",
               _index: "residents-v20240223013056",
               _primary_term: 1,
               _score: 1.0,
               _seq_no: 26_776,
               _source: %{"hello" => "world"},
               _version: 1
             } = Document.new(attrs)
    end

    test "returns a struct with a map of mixed key" do
      attrs = %{
        "_id" => "rvO6H4wBhbFpuyekVIiV",
        "_index" => "residents-v20240223013056",
        "_primary_term" => 1,
        "_score" => 1.0,
        _seq_no: 26_776,
        _source: %{"hello" => "world"},
        _version: 1
      }

      assert %Document{
               _id: "rvO6H4wBhbFpuyekVIiV",
               _index: "residents-v20240223013056",
               _primary_term: 1,
               _score: 1.0,
               _seq_no: 26_776,
               _source: %{"hello" => "world"},
               _version: 1
             } = Document.new(attrs)
    end

    test "returns a struct with _source as map of atoms as key" do
      attrs = %{_source: %{hello: "world"}}

      assert %Document{_source: %{hello: "world"}} = Document.new(attrs)
    end

    test "returns a struct with _source as map of atoms as binary" do
      attrs = %{_source: %{"hello" => "world"}}

      assert %Document{_source: %{"hello" => "world"}} = Document.new(attrs)
    end
  end
end
