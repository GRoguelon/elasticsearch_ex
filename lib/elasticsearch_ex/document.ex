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

  ## Module attributes

  @attributes @__struct__ |> Map.from_struct() |> Map.keys()

  @attributes_as_map @attributes
                     |> Enum.flat_map(fn key -> [{key, key}, {Atom.to_string(key), key}] end)
                     |> Enum.into(%{})

  ## Public functions

  def new(attrs \\ %{})

  @spec new([map()]) :: [t()]
  def new(attrs_list) when is_list(attrs_list) do
    Enum.map(attrs_list, &new/1)
  end

  @spec new(map()) :: t()
  def new(attrs) when is_map(attrs) do
    Enum.reduce(attrs, %__MODULE__{}, fn {key, value}, acc ->
      if casted_key = Map.get(@attributes_as_map, key) do
        Map.put(acc, casted_key, value)
      else
        raise ArgumentError,
              "unable to initialize the document with the key: `#{key}`, " <>
                "valid keys are: #{Enum.map_join(@attributes, ", ", &to_string/1)}."
      end
    end)
  end
end
