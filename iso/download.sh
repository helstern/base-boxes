#!/usr/bin/env bash

DOWNLOAD_ROOT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
# this file needs to be parametrized by architecture type and installer type

SOURCE=http://releases.ubuntu.com/12.04/ubuntu-12.04.5-server-amd64.iso
FILENAME=ubuntu-12.04-server-amd64.iso
wget --output-document=${DOWNLOAD_ROOT_DR}/${FILENAME} ${SOURCE}

SOURCE=http://releases.ubuntu.com/14.04/ubuntu-14.04.2-server-amd64.iso
FILENAME=ubuntu-14.04-server-amd64.iso
wget --output-document=${DOWNLOAD_ROOT_DIR}/${FILENAME} ${SOURCE}

SOURCE=http://dlc-cdn.sun.com/virtualbox/4.3.26/VBoxGuestAdditions_4.3.26.iso
FILENAME=VBoxGuestAdditions_4.3.26.iso
wget --output-document=${DOWNLOAD_ROOT_DIR}/${FILENAME} ${SOURCE}

SOURCE=http://download.opensuse.org/distribution/13.2/iso/openSUSE-13.2-GNOME-Live-x86_64.iso
FILENAME=openSUSE-13.2-GNOME-Live-x86_64.iso
wget --output-document=${DOWNLOAD_ROOT_DIR}/${FILENAME} ${SOURCE}

SOURCE=http://download.opensuse.org/distribution/13.2/iso/openSUSE-13.2-DVD-x86_64.iso
FILENAME=openSUSE-13.2-DVD-x86_64.iso
wget --output-document=${DOWNLOAD_ROOT_DIR}/${FILENAME} ${SOURCE}

SOURCE=http://releases.ubuntu.com/12.04/ubuntu-12.04.5-desktop-amd64.iso
FILENAME=ubuntu-12.04.5-desktop-amd64.iso
wget --output-document=${DOWNLOAD_ROOT_DIR}/${FILENAME} ${SOURCE}


