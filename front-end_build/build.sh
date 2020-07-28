#!/usr/bin/env bash
# build Front-End
SERVER_IP='192.168.60.4'

# install node version manages
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash

nvm install 12.18.2

# installl angular globally
npm install -g @angular/cli@8.3.21

# clone git repository and build front-end
git clone https://github.com/yurkovskiy/IF-105.UI.dtapi.if.ua.io.git
cd IF-105.UI.dtapi.if.ua.io
npm install && ng build

# replace server address with local ip
sed -i -e "s/https:\/\/dtapi.if.ua\/api/http:\/\/$SERVER_IP/g" \
src/environments/environment.ts

sed -i -e "s/https:\/\/dtapi.if.ua\/api/http:\/\/$SERVER_IP/g" \
src/environments/environment.prod.ts