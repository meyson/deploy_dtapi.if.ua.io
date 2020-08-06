#!/usr/bin/env bash

# clone repository if it doesn't exist otherwise just clear existing one
clone_repository() {
  local localrepo_vc_dir=$2/.git
  [ -d "$localrepo_vc_dir" ] || git clone "$1" "$2"
  (cd "$2"; git reset --hard; git pull "$1")
}

edit_be_files() {
  local app_php="$DIST_DIR_BE/application/bootstrap.php"
  local db_php="$DIST_DIR_BE/application/config/database.php"
  sed -i -e "s|RewriteBase /|RewriteBase /api|g" "$DIST_DIR_BE/.htaccess"
  sed -i -e "s|'base_url'   => '/'|'base_url'   => '/api/'|g" "$app_php"
  sed -i -e "s|'type'       => 'PDO_MySQL'|'type'       => 'PDO'|g" "$db_php"
  sed -i -e "s|localhost|$DB_IP|g" "$db_php"
}

# build Backend
build_backend() {
  cp -r koseven/modules "$DIST_DIR_BE"
  cp -r koseven/system "$DIST_DIR_BE"
  cp koseven/public/index.php "$DIST_DIR_BE"

  cp -r dtapi/application "$DIST_DIR_BE"
  cp dtapi/.htaccess "$DIST_DIR_BE"
  mkdir -p "$DIST_DIR_BE/application/cache/"
  mkdir -p "$DIST_DIR_BE/application/logs/"
  edit_be_files

  echo "Backend is ready!"
}

install_node() {
  # https://unix.stackexchange.com/questions/184508/nvm-command-not-available-in-bash-script
  source ~/.nvm/nvm.sh
  if [ "$?" != "0" ];
  then
      echo "Please install Node Version Manager."
      echo "To install or update nvm, you should run the install script."
      echo "wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash"
      echo "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash"
      exit 2
  fi
  nvm install "$1"
}

edit_fe_files() {
  # replace address in Angular env variable with local IP
  local env_folder="./src/environments"
  local env_regexp="s|https://dtapi.if.ua/api|http://$LB_IP/api|g"
  sed -i -e "$env_regexp" "$env_folder/environment.ts"
  sed -i -e "$env_regexp" "$env_folder/environment.prod.ts"
}

build_frontend() {
  cd IF-105.UI.dtapi.if.ua.io

  install_node "12.18.2"

  if ! command -v ng &> /dev/null
  then
    echo "Please install Angular 8.3.21 version globally"
    echo "npm install -g @angular/cli@8.3.21"
    exit 4
  fi

  npm install
  edit_fe_files
  ng build --prod
  cp -a ./dist/IF105/. "../$DIST_DIR"
  cp "../../new_files/fe/.htaccess" "../$DIST_DIR/"
  echo "Frontend is ready!"
  cd -
}

build_app() {
  # check env arguments
  : "${DIST_DIR:?Need to set env variable DIST_DIR non-empty}"
  : "${DIST_DIR_BE:?Need to set env variable DIST_DIR_BE non-empty}"
  : "${LB_IP:?Need to set env variable LB_IP non-empty}"
  : "${DB_IP:?Need to set env variable DB_IP non-empty}"

  cd build
  mkdir -p "$DIST_DIR_BE/"

  clone_repository https://github.com/koseven/koseven.git koseven
  clone_repository https://github.com/yurkovskiy/dtapi.git dtapi
  build_backend

  clone_repository https://github.com/yurkovskiy/IF-105.UI.dtapi.if.ua.io.git IF-105.UI.dtapi.if.ua.io
  build_frontend
  cd -
  echo "Now you can run \"vagrant up\" and check $LB_IP in your browser..."
}

help() {
  echo "Usage:"
  echo "-b, --build    Build entire application (frontend and backend)"
  echo "-c, --clean    Remove builds"
  echo "-b install or --build install additionally installs necessary dependencies"
}

install_dependencies() {
  # install node version manager
  wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

  install_node "12.18.2"
  npm install -g @angular/cli@8.3.21
}

main() {
  # from https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      -b|--build)
        if [ "$2" == "install" ];
        then
          install_dependencies
        fi
        build_app
        shift ;;
      -c|--clean)
        rm -rf build/*
        shift ;;
      -h|--help)
        help ;;
      *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
  done
}

main "$@"
