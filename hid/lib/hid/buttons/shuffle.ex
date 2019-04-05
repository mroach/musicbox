defmodule HID.Buttons.Shuffle do
  use HID.Button, pin_id: 16

  def pressed(_event), do: Musicbox.Player.shuffle()
end
