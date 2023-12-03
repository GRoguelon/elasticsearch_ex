defmodule ElasticsearchEx.MixProject do
  use Mix.Project

  @source_url "https://github.com/GRoguelon/elasticsearch_ex"
  @version "0.2.0"

  def project do
    [
      app: :elasticsearch_ex,
      version: @version,
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      name: "Elasticsearch_ex",
      description: "Elasticsearch_ex is a client library for Elasticsearch",
      docs: docs(),
      source_url: @source_url,
      dialyzer: dialyzer()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ElasticsearchEx.Application, []}
    ]
  end

  defp package do
    [
      name: :elasticsearch_ex,
      files: ["lib", "mix.exs"],
      maintainers: ["Geoffrey Roguelon"],
      licenses: ["MIT"],
      links: %{"Github" => @source_url}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "CHANGELOG.md"],
      source_ref: "v#{@version}",
      source_url: @source_url,
      groups_for_modules: [
        API: [
          ElasticsearchEx.Api.Search.Core
        ]
      ]
    ]
  end

  defp dialyzer do
    [
      plt_file: {:no_warn, "priv/plts/project.plt"},
      ignore_warnings: ".dialyzer_ignore.exs"
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:bypass, "~> 2.1", only: :test},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.30", only: :dev, runtime: false},
      {:jason, "~> 1.4"},
      {:req, "~> 0.4"}
    ]
  end
end
