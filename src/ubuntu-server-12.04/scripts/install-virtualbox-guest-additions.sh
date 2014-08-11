#!/bin/bash

set -e
set -x

# check that script is running with elevated privileges
if [ $(/usr/bin/id -u) -ne 0 ]; then
    echo "Not running as root or using sudo"
    exit 1
fi

#install linux headers
aptitude install -y linux-headers-$(uname -r)

# install support for building kernel modules
aptitude install -y dkms
# install make, not sure of the reason its needed
aptitude install -y make

# Mount the disk image
cd /tmp

MOUNT_DIR=/tmp/mount-virtualbox-guest-additions
mkdir -p ${MOUNT_DIR}

VBOX_ISO_LOCATION=/home/manager/VBoxGuestAdditions.iso
mount -t iso9660 -o loop ${VBOX_ISO_LOCATION} ${MOUNT_DIR}

# Install the drivers
${MOUNT_DIR}/VBoxLinuxAdditions.run --nox11

# Cleanup
umount -vf ${MOUNT_DIR}
#rm -rf isomount /root/VBoxGuestAdditions.iso
rm -rf ${MOUNT_DIR}