defmodule DataCompactor.MixProject do
  use Mix.Project

  def project do
    [
      app: :data_compactor,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {DataCompactor.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:brod, "~> 4.3"},
      {:emqtt, github: "emqx/emqtt", tag: "1.13.2", system_env: [{"BUILD_WITHOUT_QUIC", "1"}]},
      {:excoveralls, "~> 0.18", only: [:dev, :test], runtime: false},
      {:jason, "~> 1.4"},
      {:schema, in_umbrella: true}
    ]
  end
end
