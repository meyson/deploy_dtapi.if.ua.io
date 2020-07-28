#!/usr/bin/env bash
apt-get update
apt-get install -y apache2
apachectl configtest
apt install -y php libapache2-mod-php php-mysql

# TODO