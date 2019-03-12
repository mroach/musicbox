#!/bin/bash

/usr/bin/tvservice -n 2>&1 | grep -q "No device"

if [ $? -eq 0 ]; then
  echo "Disabling HDMI"
  /usr/bin/tvservice -o
else
  echo "HDMI cable plugged-in. Not disabling."
fi
