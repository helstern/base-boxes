#!/bin/bash

set -e
set -x

# check that script is running with elevated privileges
if [ $(/usr/bin/id -u) -ne 0 ]; then
    echo "Not running as root or using sudo"
    exit 1
fi

# https://wiki.postgresql.org/wiki/Apt#PostgreSQL_packages_for_Debian_and_Ubuntu
# https://dev.mysql.com/doc/mysql-apt-repo-quick-guide/en/index.html#apt-repo-fresh-install
# http://linuxg.net/how-to-install-redis-server-3-0-0-on-ubuntu-14-10-ubuntu-14-04-ubuntu-12-04-and-derivative-systems/
# https://www.rabbitmq.com/install-debian.html
# http://stackoverflow.com/questions/7739645/install-mysql-on-ubuntu-without-password-prompt

OS_CODENAME=$(lsb_release -cs)

echo "add postgresql repository"
cat > /etc/apt/sources.list.d/pgdg.list <<EOF
deb http://apt.postgresql.org/pub/repos/apt/ $OS_CODENAME-pgdg main
deb-src http://apt.postgresql.org/pub/repos/apt/ $OS_CODENAME-pgdg main
EOF
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

echo "add mysql repository"

export DEBIAN_FRONTEND=noninteractive
debconf-set-selections <<MYSQL_DEBCONF
mysql-apt-config mysql-apt-config/select-connector-python select none
mysql-apt-config mysql-apt-config/select-workbench select none
# Choices: mysql-5.6, mysql-5.7-dmr, none
mysql-apt-config mysql-apt-config/select-server select mysql-5.6
mysql-apt-config mysql-apt-config/select-connector-odbc select connector-odbc-x.x
mysql-apt-config mysql-apt-config/select-product select Apply
# Choices: mysql-utilities-1.5, none
mysql-apt-config mysql-apt-config/select-utilities select mysql-utilities-1.5
MYSQL_DEBCONF

MYSQL_RELEASE_PACKAGE_VERSION=0.3.5
wget http://dev.mysql.com/get/mysql-apt-config_${MYSQL_RELEASE_PACKAGE_VERSION}-1ubuntu14.04_all.deb
dpkg --install mysql-apt-config_${MYSQL_RELEASE_PACKAGE_VERSION}-1ubuntu14.04_all.deb

echo "add mongo db repository"

wget --quiet -O - http://docs.mongodb.org/10gen-gpg-key.asc | apt-key add -
cat > /etc/apt/sources.list.d/mongodb-org-3.0.list <<EOF
deb http://repo.mongodb.org/apt/ubuntu $OS_CODENAME/mongodb-org/3.0 multiverse
EOF

echo "add redis server repository"
add-apt-repository ppa:chris-lea/redis-server

echo "add rabbitmq repository"
wget --quiet -O - https://www.rabbitmq.com/rabbitmq-signing-key-public.asc | apt-key add -
cat > /etc/apt/sources.list.d/rabbitmq.list <<EOF
deb http://www.rabbitmq.com/debian/ testing main
EOF

apt-get update

apt-get install --yes --force-yes memcached redis-server mysql-server mysql-client-core-5.5 postgresql-9.4 pgadmin3 rabbitmq-server


# stop memcached from starting up
echo "manual" >> /etc/init/memcached.override
sudo update-rc.d memcached disable


# stop redis-server from starting up
echo "manual" >> /etc/init/redis-server.override
sudo update-rc.d redis-server disable


# stop mysql from starting up
echo "manual" >> /etc/init/mysql.override
sudo update-rc.d mysql disable

# stop postgresql from starting up
echo "manual" >> /etc/init/postgresql.override
sudo update-rc.d postgresql disable

# stop rabbitmq-server from starting up
echo "manual" >> /etc/init/rabbitmq-server.override
sudo update-rc.d rabbitmq-server disable
