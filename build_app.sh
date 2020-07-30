#!/usr/bin/env bash

SERVER_IP="192.168.60.3"

DB_IP="192.168.60.5"
# TODO
DATABASE="dtapi2"
DB_USER_NAME="dtapi"
DB_USER_PSWD="dtapi"

DIST_DIR="app/dtapi"
DIST_DIR_BE="app/dtapi/api"

cd build
mkdir -p "$DIST_DIR_BE/"

# build Backend
git clone https://github.com/koseven/koseven.git
cp -r koseven/modules ${DIST_DIR_BE}
cp -r koseven/system ${DIST_DIR_BE}
cp koseven/public/index.php ${DIST_DIR_BE}

git clone https://github.com/yurkovskiy/dtapi.git
cp -r dtapi/application ${DIST_DIR_BE}
cp dtapi/.htaccess ${DIST_DIR_BE}
mkdir -p "$DIST_DIR_BE/application/cache/"
mkdir -p "$DIST_DIR_BE/application/logs/"

# edit files
sed -i -e "s/RewriteBase \//RewriteBase \/api/g" "$DIST_DIR_BE/.htaccess"
sed -i -e "s/'base_url'   => '\/'/'base_url'   => '\/api\/'/g" \
"$DIST_DIR_BE/application/bootstrap.php"
sed -i -e "s/'type'       => 'PDO_MySQL'/'type'       => 'PDO'/g" \
"$DIST_DIR_BE/application/config/database.php"
sed -i -e "s/localhost/$DB_IP/g" \
"$DIST_DIR_BE/application/config/database.php"

# create .htaccess for root directory
cat <<EOF > "$DIST_DIR/.htaccess"
RewriteEngine On
# -- REDIRECTION to https (optional):
# If you need this, uncomment the next two commands
# RewriteCond %{HTTPS} !on
# RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI}
# --
RewriteCond %{DOCUMENT_ROOT}%{REQUEST_URI} -f [OR]
RewriteCond %{DOCUMENT_ROOT}%{REQUEST_URI} -d

RewriteRule ^.*$ - [L]
RewriteRule ^ index.html
EOF

# build Frontend
# install node version manager
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash

# https://unix.stackexchange.com/questions/184508/nvm-command-not-available-in-bash-script
. ~/.nvm/nvm.sh

nvm install 12.18.2

# installl angular globally
npm install -g @angular/cli@8.3.21

# clone git repository and build front-end
git clone https://github.com/yurkovskiy/IF-105.UI.dtapi.if.ua.io.git
cd IF-105.UI.dtapi.if.ua.io
npm install

# replace address in Angular env variable with local IP
ENV_REGEXP="s/https:\/\/dtapi\.if\.ua\/api/http:\/\/$SERVER_IP\/api/g"
sed -i -e ${ENV_REGEXP} src/environments/environment.ts
sed -i -e ${ENV_REGEXP} src/environments/environment.prod.ts

ng build --prod
cp -a ./dist/IF105/. ../${DIST_DIR}

echo "Now you can run vagrant up and check $SERVER_IP in your browser"