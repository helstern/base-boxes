#!/bin/bash

set -e
set -x

# check that script is running with elevated privileges
if [ $(/usr/bin/id -u) -ne 0 ]; then
    echo "Not running as root or using sudo"
    exit 1
fi

echo "install servers"

apt-get install --yes apache2

#apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
#cat <<PASSENGER_REPO > /etc/apt/sources.list.d/passenger.list
#    deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main
#PASSENGER_REPO
#chown root: /etc/apt/sources.list.d/passenger.list
#chmod 600 /etc/apt/sources.list.d/passenger.list
#apt-get update
#
#apt-get install libapache2-mod-passenger
#a2enmod passenger

