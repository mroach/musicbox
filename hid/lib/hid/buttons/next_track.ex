defmodule HID.Buttons.NextTrack do
  use HID.Button, pin_id: 5

  def pressed(_event), do: Musicbox.Player.next()

  def released(_), do: :noop
end
