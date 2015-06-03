#!/bin/bash

set -e
set -x

RUBY_USER=manager
RUBY_GROUP=manager

CURRENT_USER=$(whoami)

if [ "${CURRENT_USER}" != "${RUBY_USER}" ]; then
    echo "Must run this script as ${RUBY_USER} instead of ${CURRENT_USER}"
    exit 1
fi

curl -sSL https://rvm.io/mpapis.asc | gpg --import -

echo "install rvm in single user (${RUBY_USER}) mode"
echo "see https://rvm.io/rvm/install"

curl -sSL https://get.rvm.io | bash -s stable --ruby

RUBY_INSTALL_VERSION=0.5.0
echo "install ruby-install ${RUBY_INSTALL_VERSION}"

wget -O "ruby-install-${RUBY_INSTALL_VERSION}.tar.gz" "https://github.com/postmodern/ruby-install/archive/v${RUBY_INSTALL_VERSION}.tar.gz"
tar -xzvf "ruby-install-${RUBY_INSTALL_VERSION}.tar.gz"
cd "ruby-install-${RUBY_INSTALL_VERSION}/"
sudo make install

CHRUBY_VERSION=0.3.9
echo "install chruby ${CHRUBY_VERSION}"

wget -O "chruby-${CHRUBY_VERSION}.tar.gz" "https://github.com/postmodern/chruby/archive/v${CHRUBY_VERSION}.tar.gz"
tar -xzvf "chruby-${CHRUBY_VERSION}.tar.gz"
cd "chruby-${CHRUBY_VERSION}/"
sudo make install

RUBY_VERSIONS="2.1.3 2.2.1"
for ruby_version in ${RUBY_VERSIONS}; do
    ruby-install --rubies-dir ~/.rvm/rubies ruby "${ruby_version}"
done

source /usr/local/share/chruby/chruby.sh
source /usr/local/share/chruby/auto.sh
# required for chruby
RUBIES+=(~/.rvm/rubies/*)

RUBY_GEMS="bundler passenger rails"
for ruby_version in ${RUBY_VERSIONS}; do
    chruby ruby "${ruby_version}"
    for package in ${RUBY_GEMS}; do
        gem install "${package}"
    done
done

