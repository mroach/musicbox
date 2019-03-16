FROM debian:stretch AS builder

ENV DEBIAN_FRONTEND=noninteractive \
    NINJA_VER=1.9.0 \
    MESON_VER=0.50.0 \
    MPD_VER=0.21.5

RUN apt-get update && \
    apt-get -yqq install build-essential \
                         libboost-dev \
                         python3-minimal \
                         curl && \
    apt-get -yqq install libasound2-dev \
                         libmpg123-dev \
                         libid3tag0-dev \
                         libaudiofile-dev \
                         libfaad-dev \
                         libflac-dev \
                         libsqlite3-dev

WORKDIR /build

RUN mkdir /build/release

RUN curl -L -o ninja.tar.gz https://github.com/ninja-build/ninja/archive/v${NINJA_VER}.tar.gz && \
    tar xf ninja.tar.gz && \
    rm ninja.tar.gz && \
    (cd ninja-${NINJA_VER} && python3 configure.py --bootstrap && mv ninja /usr/local/bin) && \
    rm -rf ninja-${NINJA_VER}

# meson doesn't have to be installed
RUN curl -Lo meson.tar.gz https://github.com/mesonbuild/meson/releases/download/0.50.0/meson-0.50.0.tar.gz && \
    tar xf meson.tar.gz && \
    rm meson.tar.gz

RUN curl -L -o mpd.tar.xz http://www.musicpd.org/download/mpd/0.21/mpd-${MPD_VER}.tar.xz && \
    tar xf mpd.tar.xz && \
    rm mpd.tar.xz && \
    ./meson-${MESON_VER}/meson.py mpd-${MPD_VER} output/release --buildtype=release && \
    ninja -C output/release && \
    cp output/release/mpd /build/release/


FROM debian:stretch AS mpd-light

RUN apt-get update && \
    apt-get -yqq install libasound2 \
                        libmpg123-0 \
                        libid3tag0 \
                        libaudiofile1 \
                        libfaad2 \
                        libflac8 \
                        libsqlite3-0 \
                        libexpat1

RUN mkdir -p /mpd/conf /mpd/music /mpd/playlists /mpd/data/state /mpd/data/tag_cache

COPY --from=builder /build/release/mpd /usr/local/bin/
COPY ./conf/mpd.conf /mpd/conf/

VOLUME ["/mpd/conf", "/mpd/music", "/mpd/playlists", "/mpd/data"]

EXPOSE 6600

CMD ["/usr/local/bin/mpd", "--no-daemon", "--stdout", "/mpd/conf/mpd.conf"]
