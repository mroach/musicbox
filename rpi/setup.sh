#!/bin/bash

#
# This script will do a first time setup of a virgin Raspberry Pi running a
# fresh install of Raspbian. It:
#
# * Installs build tools and SSH server
# * Disables exim, avahi, apt daily tasks
# * Adds authorized SSH keys
# * Installs Elixir
# * Installs startup scripts
# * Enables SPI
#

source /etc/os-release

if [ "$ID" != "Raspbian" ]; then
  echo "This script is only for running on Raspbian, not ${NAME} (${ID})"
  exit 1
fi

if [ $UID -ne 0 ]; then
  echo "Must be root"
  exit 1
fi

echo "-------------------------------------------------------------------------"
echo "  Configuring `cat /proc/device-tree/model`"
echo "-------------------------------------------------------------------------"

# To simplify local/user rc files, create /etc/rc.local.d
# Then replace the default /etc/rc.local with ours that will run
# every file in /etc/rc.local.d
cp -r ./etc/rc.local.d /etc/
cp ./etc/rc.local /etc/

apt-get install -y build-essential openssh-server

systemctl enable ssh.service
systemctl start ssh.service

# Disable daily apt update
systemctl disable apt-daily-upgrade.timer
systemctl disable apt-daily.timer

# Disable services we don't care about
systemctl disable exim4
systemctl disable avahi-daemon.socket
systemctl disable avahi-daemon.service

# Add SSH keys
mkdir -p /home/pi/.ssh
auth_keys_file="/home/pi/.ssh/authorized_keys"
auth_keys_tag="# mroach"
if [ ! -f ${auth_keys_file} ] || [ `grep -Ec "${auth_keys_tag}" ${auth_keys_file}` -eq 0 ]; then
  echo "${auth_keys_tag}" >> ${auth_keys_file}
  curl https://github.com/mroach.keys >> ${auth_keys_file}
  chown pi:pi ${auth_keys_file}
fi

# Install Elixir
if [ ! -f /etc/apt/sources.list.d/erlang-solutions.list ]; then
  echo "deb https://packages.erlang-solutions.com/debian stretch contrib" | \
    tee /etc/apt/sources.list.d/erlang-solutions.list
fi

apt-key adv --list-keys "434975BD900CCBE4F7EE1B1ED208507CA14F4FCA" > /dev/null
if [ $? -ne 0 ]; then
  curl -O- https://packages.erlang-solutions.com/debian/erlang_solutions.asc \
    apt-key add -
fi

apt-get update && apt-get -y install elixir erlang-dev

# Enable SPI
sudo sed -i '/dtparam=spi=on/s/^#//' /boot/config.txt

echo "Done. Reboot please."
