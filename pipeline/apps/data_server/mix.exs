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
      {:mongodb_driver, "~> 1.5.0"},
      {:schema, in_umbrella: true}
    ]
  end
end
