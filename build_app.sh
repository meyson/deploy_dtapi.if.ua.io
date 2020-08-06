#!/usr/bin/env bash

# check env arguments
: "${DIST_DIR:?Need to set env variable DIST_DIR non-empty}"
: "${DIST_DIR_BE:?Need to set env variable DIST_DIR_BE non-empty}"
: "${LB_IP:?Need to set env variable LB_IP non-empty}"
: "${DB_IP:?Need to set env variable DB_IP non-empty}"

# build Backend
build_backend() {
  git clone https://github.com/koseven/koseven.git
  cp -r koseven/modules "$DIST_DIR_BE"
  cp -r koseven/system "$DIST_DIR_BE"
  cp koseven/public/index.php "$DIST_DIR_BE"

  git clone https://github.com/yurkovskiy/dtapi.git
  cp -r dtapi/application "$DIST_DIR_BE"
  cp dtapi/.htaccess "$DIST_DIR_BE"
  mkdir -p "$DIST_DIR_BE/application/cache/"
  mkdir -p "$DIST_DIR_BE/application/logs/"

  # edit files
  sed -i -e "s/RewriteBase \//RewriteBase \/api/g" "$DIST_DIR_BE/.htaccess"
  sed -i -e "s/'base_url'   => '\/'/'base_url'   => '\/api\/'/g" \
    "$DIST_DIR_BE/application/bootstrap.php"
  sed -i -e "s/'type'       => 'PDO_MySQL'/'type'       => 'PDO'/g" \
    "$DIST_DIR_BE/application/config/database.php"
  sed -i -e "s/localhost/$DB_IP/g" "$DIST_DIR_BE/application/config/database.php"
  echo "Backend is ready!"
}

# install node version manager and specified nodejs
install_node() {
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
  # https://unix.stackexchange.com/questions/184508/nvm-command-not-available-in-bash-script
  . ~/.nvm/nvm.sh
  nvm install "$1"
}

build_frontend() {
  # clone git repository and build front-end
  git clone https://github.com/yurkovskiy/IF-105.UI.dtapi.if.ua.io.git
  cd IF-105.UI.dtapi.if.ua.io

  install_node "12.18.2"
  # install Angular CLI 8.3.21 globally
  npm install -g @angular/cli@8.3.21

  npm install

  # replace address in Angular env variable with local IP
  local env_regexp="s/https:\/\/dtapi\.if\.ua\/api/http:\/\/$LB_IP\/api/g"
  sed -i -e "$env_regexp" src/environments/environment.ts
  sed -i -e "$env_regexp" src/environments/environment.prod.ts

  ng build --prod
  cp -a ./dist/IF105/. "../$DIST_DIR"
  echo "Frontend is ready!"
  cd -
}

main() {
  cd build
  mkdir -p "$DIST_DIR_BE/"

  build_backend
  build_frontend

  # copy new files
  cp -a "../new_files/." "$DIST_DIR/"
  echo "Now you can run \"vagrant up\" and check $LB_IP in your browser..."
}

main "$@"
