defmodule HID.Buttons.PlayPause do
  use HID.Button, pin_id: 26

  def pressed(_event), do: Musicbox.Player.toggle()

  def released(_), do: :noop
end
