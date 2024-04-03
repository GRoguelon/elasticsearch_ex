defmodule ElasticsearchEx.StreamTest do
  use ElasticsearchEx.ConnCase

  alias ElasticsearchEx.Stream

  ## Module attributes

  @index_name "test_stream"

  @query %{query: %{match_all: %{}}}

  ## Tests

  setup_all do
    on_exit(fn -> delete_index(@index_name) end)
    create_index(@index_name, %{message: %{type: :keyword}})
    stream = Stream.stream(@query, @index_name, per_page: 1, keep_alive: "5s")

    {:ok, doc_ids: index_documents(@index_name, 3), stream: stream}
  end

  describe "stream/2" do
    test "returns a Stream", %{stream: stream} do
      assert is_function(stream, 2)
    end

    @tag capture_log: true
    test "runs the Stream", %{doc_ids: [doc_id1 | [doc_id2 | [doc_id3]]], stream: stream} do
      assert [
               %{
                 "_id" => ^doc_id1,
                 "_index" => @index_name,
                 "_score" => nil,
                 "_source" => %{"message" => "Hello World 1!"},
                 "sort" => [0]
               },
               %{
                 "_id" => ^doc_id2,
                 "_index" => @index_name,
                 "_score" => nil,
                 "_source" => %{"message" => "Hello World 2!"},
                 "sort" => [1]
               },
               %{
                 "_id" => ^doc_id3,
                 "_index" => @index_name,
                 "_score" => nil,
                 "_source" => %{"message" => "Hello World 3!"},
                 "sort" => [2]
               }
             ] = Enum.to_list(stream)
    end

    @tag capture_log: true
    test "runs the Stream with desc order", %{doc_ids: [doc_id1 | [doc_id2 | [doc_id3]]]} do
      stream =
        @query
        |> Map.put(:sort, [%{message: :desc}])
        |> Stream.stream(@index_name, per_page: 1, keep_alive: "5s")

      assert [
               %{
                 "_id" => ^doc_id3,
                 "_index" => @index_name,
                 "_score" => nil,
                 "_source" => %{"message" => "Hello World 3!"},
                 "sort" => ["Hello World 3!", 2]
               },
               %{
                 "_id" => ^doc_id2,
                 "_index" => @index_name,
                 "_score" => nil,
                 "_source" => %{"message" => "Hello World 2!"},
                 "sort" => ["Hello World 2!", 1]
               },
               %{
                 "_id" => ^doc_id1,
                 "_index" => @index_name,
                 "_score" => nil,
                 "_source" => %{"message" => "Hello World 1!"},
                 "sort" => ["Hello World 1!", 0]
               }
             ] = Enum.to_list(stream)
    end
  end
end
