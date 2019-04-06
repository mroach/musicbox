# Audio

Audio is a small but important component to the `musicbox` that handles and supervises the startup of `mpd` on firmware boot. Additionally, it initializes the alsa driver by setting the correct audio device as well as a base mixer volume.

##### Audio.Mpd

Will attempt to start and restart `mpd` in case it crashes. It opens an Elixir `Port` that is supervised and kept in state. Note that `Audio.Mpd` is not started when running `musicbox` on your host machine, as its start-up command is very system dependent and not yet configurable. For local development we suggest running an instance of mpd within docker or directly on your host machine.  
The module will also attempt to create the default directory structure that our mpd configuration expects. That can be found in `./firmware/rootfs_overlay/etc/mpd.conf`

##### Audio.Alsa

Wraps alsa initialization in a [Task](https://hexdocs.pm/elixir/Task.html) that sets the alsa **audio device** as well as an initial **mixer volume level**.
For the moment it's a "fire and forget" system command and can be improved by not relying on the sleep until the audio devices are ready on the target device. It would be great to find a way to await the availability of system services via nerves, but for now we'll have to work with retries.