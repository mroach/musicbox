defmodule HID.MixProject do
  use Mix.Project

  def project do
    [
      app: :hid,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {HID.Application, []}
    ]
  end

  defp deps do
    [
      {:circuits_gpio, "~> 0.4.1"},
    ]
  end
end
