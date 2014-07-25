#!/bin/bash

set -e
set -x

if [ ! -d ~/.ssh/authorized_keys.d ]; then
    mkdir -p ~/.ssh/authorized_keys.d
fi

if [ ! -f ~/.ssh/authorized_keys ]; then
    touch ~/.ssh/authorized_keys
    chmod 0600 ~/.ssh/authorized_keys
fi

# radu.helstern's key
wget \
    --output-document ~/.ssh/authorized_keys.d/radu.helstern.key \
    https://raw.githubusercontent.com/helstern/public-keys/master/radu-ssh-default-rsa.pub
cat ~/.ssh/authorized_keys.d/radu.helstern.key >>  ~/.ssh/authorized_keys

# vagrant's key
wget \
    --output-document ~/.ssh/authorized_keys.d/vagrant.key \
    https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub
cat ~/.ssh/authorized_keys.d/vagrant.key >>  ~/.ssh/authorized_keys