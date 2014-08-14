#!/bin/bash

set -e
set -x

# check that script is running with elevated privileges
if [ $(/usr/bin/id -u) -ne 0 ]; then
    echo "Not running as root or using sudo"
    exit 1
fi

mkdir -p /etc/network/interfaces.d

mv /etc/network/interfaces /etc/network/interfaces.bak

# remove generated net rules because importing the appliance will attach network cards with different macs
# rm -f /etc/udev/rules.d/70-persistent-net.rules

#loopback interface
cat <<INTERFACES > /etc/network/interfaces
#the loopback interface
auto lo
iface lo inet loopback

source /etc/network/interfaces.d/*.conf
INTERFACES

#primary interface
sudo cat <<ETHO > /etc/network/interfaces.d/010-eth0.conf
auto eth0
iface eth0 inet dhcp
ETHO

# second interface
sudo cat <<ETH1 > /etc/network/interfaces.d/015-eth1.conf
auto eth1
iface eth1 inet dhcp
ETH1
