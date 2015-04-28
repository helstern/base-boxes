#!/bin/bash

#this script will be run at the end by the installer

echo 'runnning preseed/late_command'

aptitude --assume-yes update
aptitude --assume-yes full-upgrade

# apt-file enables to find out which package provides a given file, regardless if the package is installed or not
# python-software-properties ads add-apt-repository command
# jq is a json processor
aptitude install --assume-yes install xauth git curl wget apt-file python-software-properties jq

# install virtualbox-guest-additions pre-requisites, why is make needed for this
aptitude install --assume-yes linux-headers-$(uname -r) dkms make

# install acpi acpid to allow shuting down with virsh
aptitude install acpi acpid

#update cache of apt-file
#apt-file update
