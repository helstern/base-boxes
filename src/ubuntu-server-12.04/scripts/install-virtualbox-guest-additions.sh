#!/bin/bash

set -e
set -x

#install linux headers
aptitude install -y linux-headers-$(uname -r)

# install support for building kernel modules
aptitude install -y dkms
# install make, not sure of the reason its needed
aptitude install -y make

# Mount the disk image
cd /tmp
MOUNT_DIR=/tmp/mount-virtualbox-guest-additions
VBOX_ISO_LOCATION=/home/radu
mkdir -p $MOUNT_DIR
mount -t iso9660 -o loop "$VBOX_ISO_LOCATION/VBoxGuestAdditions.iso" $MOUNT_DIR

# Install the drivers
"$MOUNT_DIR/VBoxLinuxAdditions.run"

# Cleanup
umount "$MOUNT_DIR"
#rm -rf isomount /root/VBoxGuestAdditions.iso
rm -rf "$MOUNT_DIR"
