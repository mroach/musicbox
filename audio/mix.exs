defmodule Audio.MixProject do
  use Mix.Project

  def project do
    [
      app: :audio,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      #included_applications: [:paracusia],
      extra_applications: [:logger],
      mod: {Audio, []}
    ]
  end

  defp deps do
    [
      #{:paracusia, "~> 0.2.11"}
    ]
  end
end
