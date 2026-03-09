defmodule YWeb.MixProject do
  use Mix.Project

  def project do
    [
      app: :y_web,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      compilers: Mix.compilers()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {YWeb.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:y_core, in_umbrella: true},
      {:y_repo, in_umbrella: true},
      {:y_workers, in_umbrella: true},
      {:phoenix, "~> 1.7.0"},
      {:phoenix_live_view, "~> 1.0.0"},
      {:phoenix_ecto, "~> 4.4"},
      {:redix, "~> 1.3"},
      {:jason, "~> 1.4"},
      {:bandit, "~> 1.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
      {:mox, "~> 1.0", only: :test},
      {:telemetry_metrics, "~> 1.0"},
      {:phoenix_live_dashboard, "~> 0.8"},
      {:telemetry_poller, "~> 1.0"},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.1.1",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:plug_cowboy, "~> 2.7"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "assets.setup", "assets.build"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["compile", "tailwind y_web", "esbuild y_web"],
      "assets.deploy": [
        "tailwind y_web --minify",
        "esbuild y_web --minify",
        "phx.digest"
      ]
    ]
  end
end
