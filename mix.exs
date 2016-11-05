defmodule Exostatic.Mixfile do
  use Mix.Project

  def project do
    [app: :exostatic,
     version: "0.1.0",
     elixir: "~> 1.3",
     escript: [main_module: Exostatic.CmdLine],
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :eex, :cowboy],
    mod: {Exostatic, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:cowboy, "~> 1.0"},
      {:credo, "~> 0.5.1", only: [:dev, :test]},
      {:earmark, "~> 1.0"},
      {:floki, "~> 0.11.0"},
      {:mime, "~> 1.0"},
      {:poison, "~> 3.0"},
      {:timex, "~> 3.1"},
      {:tzdata, "~> 0.5.9"}
    ]
  end
end
