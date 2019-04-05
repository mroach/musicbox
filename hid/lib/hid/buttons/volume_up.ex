defmodule HID.Buttons.VolumeUp do
  use HID.Button, pin_id: 18

  def pressed(_event), do: Musicbox.Player.volume_up()

  def released(_), do: :noop
end
