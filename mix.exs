defmodule ElasticsearchEx.MixProject do
  use Mix.Project

  @source_url "https://github.com/GRoguelon/elasticsearch_ex"
  @version "1.8.5"

  def project do
    [
      app: :elasticsearch_ex,
      version: @version,
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
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

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      name: :elasticsearch_ex,
      files: ["lib", "mix.exs"],
      maintainers: ["Geoffrey Roguelon"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Changelog" => "https://hexdocs.pm/elasticsearch_ex/changelog.html"
      }
    ]
  end

  defp docs do
    [
      formatters: ["html"],
      main: "readme",
      extras: ["README.md", "CHANGELOG.md"],
      source_ref: "v#{@version}",
      source_url: @source_url,
      skip_undefined_reference_warnings_on: ["CHANGELOG.md"],
      groups_for_modules: [
        API: [
          ElasticsearchEx.API.Cat,
          ElasticsearchEx.API.Document,
          ElasticsearchEx.API.Document.Source,
          ElasticsearchEx.API.Features,
          ElasticsearchEx.API.Info,
          ElasticsearchEx.API.Search,
          ElasticsearchEx.API.Usage
        ],
        Utils: [
          ElasticsearchEx.Client,
          ElasticsearchEx.Deserializer,
          ElasticsearchEx.Ndjson,
          ElasticsearchEx.Serializer,
          ElasticsearchEx.Sharder,
          ElasticsearchEx.Streamer
        ]
      ]
    ]
  end

  defp dialyzer do
    [
      list_unused_filters: true
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:castore, "~> 1.0", optional: true},
      {:jason, "~> 1.4"},
      {:req, "~> 0.4"},

      ## Dev dependencies
      {:benchee, "~> 1.0", only: :dev},
      {:ex_doc, "~> 0.30", only: :dev, runtime: false},
      {:mix_test_interactive, "~> 4.1", only: :dev, runtime: false},

      ## Test dependencies
      {:plug, "~> 1.15", only: :test},

      ## Dev & Test dependencies
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end
end
