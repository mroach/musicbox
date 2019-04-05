defmodule HID.Buttons.PreviousTrack do
  use HID.Button, pin_id: 6

  def pressed(_event), do: Musicbox.Player.previous()

  def released(_), do: :noop
end
