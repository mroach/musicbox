defmodule HID.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      HID.Buttons.VolumeDown,
      HID.Buttons.VolumeUp,
      HID.Buttons.PlayPause,
      HID.Buttons.PreviousTrack,
      HID.Buttons.NextTrack,
      HID.Buttons.Shuffle,
      HID.Display
    ]

    opts = [strategy: :one_for_one, name: HID.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
