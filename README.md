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
docker-compose run --rm app mix deps.get
```

### Start development environment

```shell
docker-compose up
```

Put any music files you want into `mpd/music` and they'll be detected automatically by mpd.

## Prototype

![prototype board](https://raw.githubusercontent.com/mroach/musicbox/master/docs/img/prototype-board.jpg)
