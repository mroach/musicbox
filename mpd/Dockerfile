FROM debian:stretch AS builder

RUN apt-get update && \
    apt-get -y install build-essential libboost-dev python3 curl && \
    apt-get -y install libasound2-dev \
                       libmpg123-dev \
                       libid3tag0-dev \
                       libaudiofile-dev \
                       libfaad-dev \
                       libflac-dev \
                       libsqlite3-dev

ENV NINJA_VER=1.9.0 \
    MPD_VER=0.21.5

WORKDIR /build

RUN mkdir /build/release

RUN curl -L -o ninja.tar.gz https://github.com/ninja-build/ninja/archive/v${NINJA_VER}.tar.gz && \
    tar xf ninja.tar.gz && \
    rm ninja.tar.gz && \
    (cd ninja-${NINJA_VER} && python3 configure.py --bootstrap && mv ninja /usr/local/bin) && \
    rm -rf ninja-${NINJA_VER}

RUN apt-get -y install python3-pip && pip3 install meson

RUN curl -L -o mpd.tar.xz http://www.musicpd.org/download/mpd/0.21/mpd-${MPD_VER}.tar.xz && \
    tar xf mpd.tar.xz && \
    rm mpd.tar.xz && \
    (\
      cd mpd-${MPD_VER} && \
      meson . output/release --buildtype=release && \
      ninja -C output/release \
    ) && \
    cp mpd-${MPD_VER}/output/release/mpd /build/release/


FROM debian:stretch AS mpd-light

RUN apt-get update && \
    apt-get -y install libasound2 \
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
