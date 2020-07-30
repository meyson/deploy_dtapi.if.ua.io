#!/usr/bin/env bash

VH_DOMAIN="dtapi"
SYSTEM_USER="vagrant"


# this function configures new virtual host
function configure_vhost() {
    # add new host to /etc/apache2/sites-available directory
cat <<EOF > /etc/apache2/sites-available/$1.conf
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
    a2ensite $1
}


# install apache2
apt update
apt install -y apache2
apachectl configtest

# change apache2 file priority
cat <<EOF > /etc/apache2/mods-enabled/dir.conf
<IfModule mod_dir.c>
    DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm
</IfModule>
EOF

# install php and its modules
apt install -y php libapache2-mod-php php-mysql php-mbstring php-xml
a2enmod headers
a2enmod rewrite

## copy files form host machine
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

# configure apache virtual hosts
configure_vhost ${VH_DOMAIN}
a2dissite 000-default

systemctl restart apache2
