configure_lb() {
cat <<EOF > /etc/nginx/conf.d/lb.conf
upstream lb {
    server $SERVER_IP_1:80;
    server $SERVER_IP_2:80;
}
# custom logs
log_format upstreamlog '[\$time_local] \$remote_addr - \$remote_user - \$server_name \$host to: \$upstream_addr: \$request \$status upstream_response_time \$upstream_response_time msec \$msec request_time \$request_time';

server {
    listen $LB_IP:80;
    gzip on;
    location / {
        proxy_pass "http://lb";
    }
    access_log /var/log/nginx/access.log upstreamlog;
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
