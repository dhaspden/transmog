defmodule Transmog.MixProject do
  use Mix.Project

  def project do
    [
      app: :transmog,
      deps: deps(),
      dialyzer: [
        flags: ["-Wunmatched_returns", :error_handling, :race_conditions, :underspecs],
        remove_defaults: [:unknown]
      ],
      docs: [
        main: "Transmog",
        extras: ["README.md"]
      ],
      elixir: "~> 1.9",
      name: "Transmog",
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      source_url: "https://github.com/dhaspden/transmog",
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      version: "0.1.0"
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
end
