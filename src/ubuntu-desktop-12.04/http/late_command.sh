#!/bin/bash

set -x

#this script will be run at the end by the installer

echo 'runnning preseed/late_command'

cp /etc/udev/rules.d/70-persistent-net.rules /etc/udev/rules.d/70-persistent-net.bak
rm --force /etc/udev/rules.d/70-persistent-net.rules

apt-get install -y --force-yes xauth