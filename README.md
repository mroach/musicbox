## Musicbox

<img src="https://raw.githubusercontent.com/mroach/musicbox/master/docs/img/tech-stack.png" align="right" height="150" width="150" />

The goal is for this to be a Phoenix application running on a Raspberry Pi
to function as a simple music box for kids.

### Tech Stack

* [Music Player Daemon](https://www.musicpd.org/) - Headless music player for Linux
* [Phoenix LiveView](https://github.com/phoenixframework/phoenix_live_view) - Instantaneous web UI without writing JavaScript
* [Nerves](https://nerves-project.org/) - Creating Elixir projects as full-blown firmware images such as for booting a Raspberry Pi
* [Elixir Circuits](https://elixir-circuits.github.io/) - Elixir SDK for GPIO and SPI for managing the buttons and RFID reader

## Feature Goals

* RFID cards trigger playing songs or playlists
* Web interface to manage playlists, upload new music, pair new cards
* Buttons to control playback

# Development

* `app/` - Phoenix web application
* `mpd/` - Custom lightweight build of [mpd](https://www.musicpd.org/)
* `rpi/` - Scripts to configure a fresh install of Raspbian. May be obviated by using Nerves

This application is Dockerized. With Docker and docker-compose installed:

### First time:

```shell
docker-compose build
```

### Start development environment

On Linux we can mount `/dev/snd` in the Docker container and mpd can directly
use our host system's sound output.

macOS doesn't have `/dev/snd` or ALSA, so we configure mpd to output via an HTTP/Shoutcast
server. Then on our macOS host we can use iTunes or VLC to connect to the stream.

Use `start_env.sh` to automatically pick the correct configuration.

```shell
./start_env.sh
```

Put any music files you want into `mpd/music` and they'll be detected automatically by mpd.

## Prototype

![prototype board](https://raw.githubusercontent.com/mroach/musicbox/master/docs/img/prototype-board.jpg)
