defmodule ElasticsearchEx.Document do
  @moduledoc """
  Provides a struct to represent a document from Elasticsearch.
  """

  defstruct [
    :_id,
    :_index,
    :_primary_term,
    :_seq_no,
    :_source,
    :_score,
    :_version,
    :found,
    :result,
    :_shards
  ]

  ## Typespecs

  @type t :: %__MODULE__{
          _id: nil | binary(),
          _index: nil | binary(),
          _primary_term: nil | pos_integer(),
          _seq_no: nil | non_neg_integer(),
          _source: map(),
          _score: nil | float(),
          _version: nil | pos_integer(),
          found: nil | boolean(),
          result: nil | binary(),
          _shards: nil | %{required(atom() | binary()) => non_neg_integer()}
        }

  ## Public functions

  def new(attrs \\ %{})

  @spec new([map()]) :: [t()]
  def new(attrs_list) when is_list(attrs_list) do
    Enum.map(attrs_list, &new/1)
  end

  @spec new(map()) :: t()
  def new(attrs) when is_map(attrs) do
    case Enum.at(attrs, 0) do
      {key, _} when is_atom(key) ->
        struct!(__MODULE__, attrs)

      {key, _} when is_binary(key) ->
        attrs = Map.new(attrs, fn {key, value} -> {String.to_existing_atom(key), value} end)

        struct!(__MODULE__, attrs)

      nil ->
        __MODULE__.__struct__()
    end
  end
end
