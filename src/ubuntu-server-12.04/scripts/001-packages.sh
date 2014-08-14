#!/bin/bash

set -e
set -x

# check that script is running with elevated privileges
if [ $(/usr/bin/id -u) -ne 0 ]; then
    echo "Not running as root or using sudo"
    exit 1
fi

aptitude --assume-yes update
aptitude --assume-yes full-upgrade

#install virtualbox-guest-additions pre-requisites

aptitude install -y linux-headers-$(uname -r)
# install support for building kernel modules, why is make needed for this
aptitude install -y dkms make
