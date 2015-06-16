#!/bin/bash

set -e
set -x

# check that script is running with elevated privileges
if [ $(/usr/bin/id -u) -ne 0 ]; then
    echo "Not running as root or using sudo"
    exit 1
fi

echo "install pre-requisites"

apt-get install --yes build-essential \
                            libyaml-dev \
                            libreadline-dev \
                            openssl \
                            curl \
                            git \
                            git-core \
                            zlib1g-dev \
                            bison \
                            libxml2-dev \
                            libxslt1-dev \
                            libsqlite3-dev \
                            sqlite3


apt-get install --yes python-software-properties software-properties-common
