#!/bin/bash

wget https://setup.ius.io/ -O ius.sh
chmod +x ius.sh
./ius.sh
yum update -y

yum install git2u nginx tmux2u -y
fun_set_text_color(){
    COLOR_RED='\E[1;31m'
    COLOR_GREEN='\E[1;32m'
    COLOR_YELOW='\E[1;33m'
    COLOR_BLUE='\E[1;34m'
    COLOR_PINK='\E[1;35m'
    COLOR_PINKBACK_WHITEFONT='\033[45;37m'
    COLOR_GREEN_LIGHTNING='\033[32m \033[05m'
    COLOR_END='\E[0m'
}
fun_input_vhost_http_port(){
    def_vhost_http_port="8000"
    echo ""
    echo -n -e "Please input frps ${COLOR_GREEN}vhost_http_port${COLOR_END} [1-65535]"
    read -p "(Default vhost_http_port: ${def_vhost_http_port}):" input_vhost_http_port
    [ -z "${input_vhost_http_port}" ] && input_vhost_http_port="${def_vhost_http_port}"
}

fun_set_text_color
fun_input_vhost_http_port
def_subdomain_host="frps.com"
read -p "Please input subdomain_host (Default: ${def_subdomain_host}):" set_subdomain_host
[ -z "${set_subdomain_host}" ] && set_subdomain_host="${def_subdomain_host}"
echo "frps subdomain_host: ${set_subdomain_host}"
echo ""

cat > /etc/nginx/conf.d/frps.conf<<-EOF
upstream ngrok {
    server 127.0.0.1:${input_vhost_http_port};
    keepalive 64;
}

server {
    listen       80;
    server_name  *.${set_subdomain_host};

    #charset koi8-r;
    #access_log  /var/log/nginx/log/host.access.log  main;

    location / {
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Host  \$http_host:${input_vhost_http_port};
        proxy_set_header X-Nginx-Proxy true;
        proxy_set_header Connection "";
        proxy_pass      http://ngrok;

    }
}
EOF

nginx -s reload
