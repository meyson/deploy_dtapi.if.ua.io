configure_lb() {
cat <<EOF > /etc/nginx/conf.d/lb.conf
upstream lb {
    ip_hash;
    server $SERVER_IP_1:80;
    server $SERVER_IP_2:80;
}

server {
    listen $LB_IP:80;

    location / {
        proxy_pass "http://lb";
    }
}
EOF
systemctl reload nginx
}

install_nginx() {
  yum install -y epel-release
  yum install -y nginx
  systemctl start nginx
  systemctl enable nginx
  setsebool httpd_can_network_connect on -P
}

install_nginx
configure_lb
