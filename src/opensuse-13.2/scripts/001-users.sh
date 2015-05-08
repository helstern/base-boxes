#!/bin/bash

set -e
set -x

# check that script is running with elevated privileges
if [ $(/usr/bin/id -u) -ne 0 ]; then
    echo "Not running as root or using sudo"
    exit 1
fi

#create an admin group, which will contain users that will have passwordless sudo
groupadd admin
cat <<PASWORDLESS > /etc/sudoers.d/0001-sudo-passwordless

#when sudo is invoked, keep the established ssh sock
Defaults env_keep="SSH_AUTH_SOCK"

#allow passwordless sudo for admin and vagrant
%admin ALL=NOPASSWD: ALL

PASWORDLESS
chmod 0440 /etc/sudoers.d/0001-sudo-passwordless

#create vagrant user, with home dir and additionaly
groupadd vagrant
useradd --create-home --gid vagrant vagrant
#set vagrant as password for usr vagrant
echo vagrant:vagrant | chpasswd

#members of passwordless sudo
usermod --append --groups admin vagrant
usermod --append --groups admin manager
