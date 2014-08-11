#!/bin/bash

#this script will be run at the end by the installer

echo 'runnning preseed/late_command'

cp /etc/udev/rules.d/70-persistent-net.rules /etc/udev/rules.d/70-persistent-net.bak
rm /etc/udev/rules.d/70-persistent-net.rules

apt-get update -y
apt-get upgrade -y --force-yes

apt-get install -y --force-yes xauth
