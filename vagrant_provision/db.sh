#!/usr/bin/env bash

# GLOBAL VARS
DB_DAMP_URL="https://dtapi.if.ua/~yurkovskiy/dtapi_full.sql"
DB_TABLE_URL="https://dtapi.if.ua/~yurkovskiy/IF-108/sessions.sql"

install_mysql() {
  apt update
  apt install -y mysql-server
  # allow access from outside
  echo "bind-address = $DB_IP" >> /etc/mysql/mysql.conf.d/mysqld.cnf
}

mysql_create_user() {
mysql << EOF
CREATE USER '$1'@'$3' IDENTIFIED BY '$2';
GRANT ALL PRIVILEGES ON * . * TO '$1'@'$3';
FLUSH PRIVILEGES;
EOF
}

mysql_import() {
  mysql -e "CREATE DATABASE $DATABASE;"
  if [[ -n "$DB_DAMP_URL" ]]; then
    wget -q $DB_DAMP_URL -O "/tmp/dtapi_full.sql"
  else
    echo "Url not specified"
    exit 1
  fi

  if [[ -n "$DB_TABLE_URL" ]]; then
    wget -q $DB_TABLE_URL -O "/tmp/sessions.sql"
  else
    echo "Url not specified"
    exit 1
  fi

  mysql "$DATABASE" < "/tmp/dtapi_full.sql"
  mysql "$DATABASE" < "/tmp/sessions.sql"
}

main() {
  install_mysql
  mysql_import
  mysql_create_user "$DB_USER_NAME" "$DB_USER_PWD" "$SERVER_IP_1"
  mysql_create_user "$DB_USER_NAME" "$DB_USER_PWD" "$SERVER_IP_2"
  service mysql restart
}

main "$@"
