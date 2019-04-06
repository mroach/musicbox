## Firmware

This is the firmware provider of `musicbox`. It is a nerves app that bundles and configures dependencies (poncho-style) and eventually boots on given hardware [target](https://hexdocs.pm/nerves/targets.html#supported-targets-and-systems).
The firmware uses a customized system configuration of nerves that builds `mpd`, `sqlite` and other audio related dependencies to the firmware image.  
The included system services will be included in the image and can be controlled via operating system commands (`:os.cmd/1`) or the elixir [Port](https://hexdocs.pm/elixir/Port.html) module.  

##### Getting started

Checkout the `custom_rpi3` submodule that is a fork of the [base Nerves System configuration for the Raspberry Pi 3 Model B](https://github.com/nerves-project/nerves_system_rpi3) and fetch its dependencies.

```
$ git submodule update --remote
$ cd custom_rpi3
$ mix deps.get
```

This downloads the released artifact which is required for creating the firmware image.

<hr />

Our image boots and connects to a wifi network that we configure with environment variables at _build_ time. Nerves also requires a `MIX_TARGET` that selects our customized nerves-system which includes mpd as our main dependency and builds the final firmware image from.

```
$ cd firmware
$ mix deps.get
$ export MIX_TARGET=custom_rpi3
$ export NERVES_NETWORK_SSID=networkname
$ export NERVES_NETWORK_PSK=networkpass
$ export LIVE_VIEW_SIGNING_SALT=O2q2Vdcd
```

To create the firmware image:

```
$ mix firmware
```

To burn the firmware image to an sd-card that is connected and auto-detected on your local machine:

```
$ mix firmware.burn
```

For remote firmware updates, burn the image with a [correct network configuration](https://hexdocs.pm/nerves/getting-started.html#connecting-to-your-nerves-target) to card once: Set the correct wireless network device (`wlan0` for the Raspberry Pi 3) in `config.exs` and make sure you have set the `NERVES_NETWORK_` environment variables. Of course you can connect via `LAN` or a `usb` cable.

To update the firmware remotely:

```
$ mix firmware.push
```

If that does not work for you, follow the instructions given. After generating the upload script, make sure to pass the correct destination domain that is set in `config/config.exs`.

```
./upload.sh your-nerves.local

```
## Tutorial

#### How to create your customized nerves system, archive it and make it available to other developers

Before starting, make sure you have installed all [dependencies](https://hexdocs.pm/nerves/installation.html#content) on your host machine.

1) Fork one of the [nerves base systems](https://github.com/nerves-project/nerves_system_br) that include Buildroot for your chosen target. If you cloned one of the main repositories instead of forking them, make sure to set origin and upstream remotes to stay up to date, but not interfere with the main repos.

```
$ git clone ... your_custom_rpi3
$ cd your_custom_rpi3
```

2) Rename the main module name of your customized target system in `mix.exs` and comment out the artifact section so we don't try to download an artifact that does not exist yet. The [official docs](https://hexdocs.pm/nerves/systems.html#customizing-your-own-nerves-system) are providing great step by step explanations for this. To follow these steps is crucial as otherwise you will keep building firmware from one of the official base systems and not your customized one.


3) Set your new mix target and start the nerves system shell

```
$ export MIX_TARGET=your_custom_rpi3
$ mix deps.get
$ mix nerves.system.shell
> make menuconfig
```

4) You should be presented the [Buildroot](https://buildroot.org/) editor. Browse through it, search with `/` and select the dependencies you want available on your firmware image. Once satisfied, exit your way out, back to the nerves system shell and save your configuration with

```
> make savedefconfig
```

That will save the configuration to `nerves_defconfig` and your system is ready to be archived in a locally cached artifact. This takes about half an hour, but ideally, you'll have to do it only once :)  
The official docs give more information on configuring the linux kernel as well as busybox, the bash-like environment of a nerves system.

5) Build the artifact

```
$ mix nerves.artifact
```

6) Optional: create a github release with your artifact so you can so you can use it without having to keep the quite large artifact locally in `~/.nerves/artifacts`.  
Ucomment the artifact_site config in `mix.exs`

```
artifact_sites: [
  {:github_releases, "your-github-namespace/#{@app}"}
],
```

```
$ git add mix.exs 
$ git commit -m 'set nerves target name and github release'
$ git add -am 'configure nerves base system'
$ git push
```

You'll find a tarball of the artifact in the current directory. Create a release on github and add the artifact as an asset to make it available and not depend on the locally cached artifact.
Once the release is available, run `mix deps.get` again to fetch the artifact and make sure everything works.

7) Done! You created a customized nerves system that you can use as `MIX_TARGET` in a nerves application.
