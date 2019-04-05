defmodule HID.Buttons.VolumeDown do
 use HID.Button, pin_id: 17

  def pressed(_event), do: Musicbox.Player.volume_down()

  def released(_), do: :noop
end
