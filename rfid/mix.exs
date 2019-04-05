defmodule RFID.MixProject do
  use Mix.Project

  def project do
    [
      app: :rfid,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {RFID.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:rc522, "~> 0.1.0", github: "mroach/rc522_elixir"}
    ]
  end
end
