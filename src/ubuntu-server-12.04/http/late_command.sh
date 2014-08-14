#!/bin/bash

#this script will be run at the end by the installer

echo 'runnning preseed/late_command'

# disable udev net rules
mv /etc/udev/rules.d/70-persistent-net.rules /etc/udev/rules.d/70-persistent-net.rules.disabled
touch /etc/udev/rules.d/70-persistent-net.rules
touch /etc/udev/rules.d/75-persistent-net-generator.rules

apt-get -y --force-yes install xauth