defmodule YWorkers.MixProject do
  use Mix.Project

  def project do
    [
      app: :y_workers,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {YWorkers.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:y_core, in_umbrella: true},
      {:y_repo, in_umbrella: true},
      {:oban, "~> 2.17"}
    ]
  end
end
