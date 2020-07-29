#!/usr/bin/env bash

# GLOBAL VARS
DB_DAMP_URL="https://dtapi.if.ua/~yurkovskiy/dtapi_full.sql"
DATABASE="dtapi2"
DB_USER_NAME="dtapi"
DB_USER_PSWD="dtapi"
DB_USER_HOST="192.168.60.4"
DB_IP="192.168.60.5"


# install mysql
apt update
apt install -y mysql-server

# import database dtapi2
mkdir -p Downloads/sql
cd Downloads/sql

if [[ -n "$DB_DAMP_URL" ]]; then
    wget -q $DB_DAMP_URL -O dtapi_full.sql
else
    echo "import from dtapi_full.sql file..."
fi

mysql -e "CREATE DATABASE $DATABASE;"
mysql dtapi2 < dtapi_full.sql

# configure users
mysql << EOF
CREATE USER '$DB_USER_NAME'@'$DB_USER_HOST' IDENTIFIED BY '$DB_USER_PSWD';
GRANT ALL PRIVILEGES ON * . * TO '$DB_USER_NAME'@'$DB_USER_HOST';
FLUSH PRIVILEGES;
EOF
# allow access from outside
echo "bind-address = $DB_IP" >> /etc/mysql/mysql.conf.d/mysqld.cnf

service mysql restart
