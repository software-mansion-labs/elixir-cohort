defmodule Cohort.Sample.MixProject do
  use Mix.Project

  def project do
    [
      app: :cohort_sample,
      version: "0.1.0",
      elixir: "~> 1.12-rc",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Cohort.Sample.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cohort_core, path: "../cohort_core"},
    ]
  end
end
