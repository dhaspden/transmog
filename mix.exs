defmodule Transmog.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :transmog,
      consolidate_protocols: Mix.env() != :test,
      deps: deps(),
      description: description(),
      dialyzer: [
        flags: ["-Wunmatched_returns", :error_handling, :race_conditions, :underspecs],
        remove_defaults: [:unknown]
      ],
      docs: [
        canonical: "https://hexdocs.pm/transmog",
        extras: ["README.md"],
        main: "Transmog",
        source_ref: "v#{@version}",
        source_url: "https://github.com/dhaspden/transmog"
      ],
      elixir: "~> 1.9",
      name: "Transmog",
      package: [
        files: [
          ".credo.exs",
          ".formatter.exs",
          "mix.exs",
          "README.md",
          "lib"
        ],
        licenses: ["MIT"],
        links: %{"Github" => "https://github.com/dhaspden/transmog"},
        maintainers: ["Dylan Aspden"]
      ],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      source_url: "https://github.com/dhaspden/transmog",
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      version: @version
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.1.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:excoveralls, "~> 0.10", only: :test}
    ]
  end

  defp description do
    """
    Transmog is a module which allows for easy transformations to be made to
    deeply nested maps, lists and structs. It is useful mapping keys on maps
    to new values in a way that is easily reproducible. One case where you may
    want Transmog is when converting map keys on values from external API to
    match an internal format.
    """
  end
end
