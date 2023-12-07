defmodule ElasticsearchEx.ConnCase do
  @moduledoc """
  Provides a base to test the HTTP adapters
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import ElasticsearchEx.ConnCase
    end
  end

  setup do
    bypass = Bypass.open(port: 62_421)

    {:ok, bypass: bypass}
  end
end
