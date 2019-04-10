#!/bin/bash

output="http"

[ -e /dev/snd ] && output="alsa"

echo "-------------------------------------------------------------------------"
if [[ $output == "alsa" ]]; then
  echo "mpd is being started in ALSA output mode."
  echo "Sound will be output via the host system's sound card"
elif [[ $output == "http" ]]; then
  echo "mpd is being started in HTTP/Shoutcast output mode"
  echo "You can listen to the output by connecting to the HTTP stream:"
  echo
  echo "http://localhost:8060" # check docker-compose.http.conf for the port
  echo
  echo "Warning: Volume control does not work when using HTTP output!"
fi
echo "-------------------------------------------------------------------------"

docker-compose -f docker-compose.yml -f docker-compose.${output}.yml up
