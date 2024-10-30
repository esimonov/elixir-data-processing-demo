defmodule Schema.MixProject do
  use Mix.Project

  def project do
    [
      app: :schema,
      version: "0.1.0",
      build_path: "../../_build",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.17",
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:protobuf, "~> 0.13"},
      {:google_protos, "~> 0.4"}
    ]
  end
end
