#!/bin/bash

# With no devices plugged-in, there will only be "devices" at "1" and "1.1"
# If any devices beyond that are detected, such as 1.2, don't disable USB.
cat /sys/bus/usb/devices/**/devpath | grep -Eq '^[1-9]+\.[2-9]'

if [ $? -eq 0 ]; then
  echo "USB devices attached. Quitting."
  exit 1
fi

# Disabling the USB controller also disables Ethernet, so don't do that
# if there's an Ethernet cable plugged-in.
if [ `cat /sys/class/net/eth0/carrier` != "0" ]; then
  echo "Ethernet cable is plugged-in. Aborting."
  exit 2
fi

echo "Disabling USB interface"
echo '1-1' > /sys/bus/usb/drivers/usb/unbind
