#!/bin/bash

set -e
set -x

# check that script is running with elevated privileges
if [ $(/usr/bin/id -u) -ne 0 ]; then
    echo "Not running as root or using sudo"
    exit 1
fi

function mkdir_ssh () {

    if [ ! -d /home/$1/.ssh/authorized_keys.d ]; then
        mkdir -p /home/$1/.ssh/authorized_keys.d
    fi

    if [ ! -f /home/$1/.ssh/authorized_keys ]; then
        touch /home/$1/.ssh/authorized_keys
    fi
}

function add_authorized_key_ssh () {
    cp $1 /home/$2/.ssh/authorized_keys.d
    cat $1 >>  /home/$2/.ssh/authorized_keys
}

function set_permissions_ssh () {

    chmod -R 0700 /home/$1/.ssh
    chmod 0600 /home/$1/.ssh/authorized_keys

    chown -R $1:$1 /home/$1/.ssh
}

# create .ssh file structure
mkdir_ssh manager
mkdir_ssh vagrant

# radu.helstern's public key
wget \
    --output-document /tmp/radu.helstern.key.pub \
    https://raw.githubusercontent.com/helstern/public-keys/master/radu-ssh-default-rsa.pub

add_authorized_key_ssh /tmp/radu.helstern.key.pub manager
add_authorized_key_ssh /tmp/radu.helstern.key.pub vagrant

rm /tmp/radu.helstern.key.pub

# vagrant's public key
wget \
    --output-document /tmp/vagrant.key.pub \
    https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub

add_authorized_key_ssh /tmp/vagrant.key.pub manager
add_authorized_key_ssh /tmp/vagrant.key.pub vagrant

rm /tmp/vagrant.key.pub

# vagrant's private key
wget -P /home/vagrant/.ssh https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant

# permissions
set_permissions_ssh manager
set_permissions_ssh vagrant

