defmodule DataServer.MixProject do
  use Mix.Project

  def project do
    [
      app: :data_server,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.17",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {DataServer.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:broadway, "~> 1.1"},
      {:broadway_kafka, "~> 0.4"},
      {:cowlib, "2.12.1", override: true},
      {:jason, "~> 1.4"},
      {:mox, "~> 1.0", only: :test},
      {:mongodb_driver, "~> 1.5.0"},
      {:plug, "~> 1.16"},
      {:plug_cowboy, "~> 2.7"},
      {:schema, in_umbrella: true}
    ]
  end

  defp elixirc_paths(:test), do: ["test/support", "lib"]
  defp elixirc_paths(_), do: ["lib"]
end
