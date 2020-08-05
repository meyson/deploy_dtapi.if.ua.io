#!/usr/bin/env bash

VH_DOMAIN="dtapi"
SYSTEM_USER="vagrant"

# this function configures new virtual host
configure_vhost() {
# add new host to /etc/apache2/sites-available directory
cat <<EOF > /etc/apache2/sites-available/"$1".conf
<VirtualHost *:80>
    DocumentRoot /var/www/$1
    <Directory /var/www/$1>
        AllowOverride All
    </Directory>
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF
# check $1.conf syntax
apache2ctl configtest
# enable new host
a2ensite "$1"
}

change_apache_priority() {
# change apache2 file priority
cat <<EOF > /etc/apache2/mods-enabled/dir.conf
<IfModule mod_dir.c>
    DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm
</IfModule>
EOF
}

install_apache() {
  apt update
  apt install -y apache2
  apachectl configtest
}

install_php() {
  apt install -y php libapache2-mod-php php-mysql php-mbstring php-xml
  a2enmod headers
  a2enmod rewrite
}

deploy_app() {
  # copy files form host machine
  cp -r /app/${VH_DOMAIN} /var/www/
  # change permission and ownership of www/
  cd /var/www/${VH_DOMAIN}
  chown -R ${SYSTEM_USER}:${SYSTEM_USER} .
  # for directories
  chmod -R 755 .
  # for files
  find . -type f -exec chmod 644 {} \;
  # for Koseven framework
  chmod -R a+rwx ./api/application/cache
  chmod -R a+rwx ./api/application/logs
  chmod +x ./api/application/config/session.php
}


main() {
  # install and configure apache2
  install_apache
  change_apache_priority
  # install php and its modules
  install_php
  deploy_app

  # configure apache virtual hosts
  configure_vhost ${VH_DOMAIN}
  a2dissite 000-default
  systemctl restart apache2
}

main "$@"
