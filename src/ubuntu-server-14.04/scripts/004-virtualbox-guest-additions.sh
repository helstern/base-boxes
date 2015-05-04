#!/bin/bash

#do not set -e, vbox or umount might break
set -x

# check that script is running with elevated privileges
if [ $(/usr/bin/id -u) -ne 0 ]; then
    echo "Not running as root or using sudo"
    exit 1
fi

# requires linux-headers-$(uname -r), dkms, make - see packages step

# Mount the disk image
MOUNT_DIR=/tmp/mount-virtualbox-guest-additions
mkdir -p ${MOUNT_DIR}

VBOX_ISO_LOCATION=/home/manager/VBoxGuestAdditions.iso
mount -t iso9660 -o loop ${VBOX_ISO_LOCATION} ${MOUNT_DIR}

# Install the drivers
${MOUNT_DIR}/VBoxLinuxAdditions.run

# Cleanup
umount -vf ${MOUNT_DIR}
#rm -rf isomount /root/VBoxGuestAdditions.iso
rm -rf ${MOUNT_DIR}