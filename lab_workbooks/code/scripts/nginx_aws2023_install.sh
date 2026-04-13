#!/bin/bash
######################################################
## Script to install and configure Nginx on AWS EC2 ##
######################################################

set -euxo pipefail

#####################
### User Data Log ###
#####################
exec > >(tee /var/log/user-data.log | logger -t user-data ) 2>&1

#####################
### Update System ###
#####################
sudo dnf -y update
sudo dnf -y upgrade

#########################
### Install Firewalld ###
#########################
sudo dnf -y install firewalld
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --zone=public --permanent --add-service=ssh
sudo firewall-cmd --zone=public --permanent --add-service=http
sudo firewall-cmd --zone=public --permanent --add-service=https
sudo firewall-cmd --reload

#####################
### Install Nginx ###
#####################
sudo dnf -y install nginx
sudo systemctl enable --now nginx

###############################
### Configure Nginx Website ###
###############################
sudo mv /usr/share/nginx/html/index.html index.html.bak
sudo mkdir /etc/pki/nginx/
sudo bash -c 'cat > /usr/share/nginx/html/index.html << EOF
<html>
    <head>
        <title>Welcome to Intro to Terraform!</title>
    </head>
    <body><font size="20">
        <p>Welcome to Intro to Terraform!</p>
    </font></body>
</html>
EOF'

#######################
### Configure Nginx ###
#######################
sudo mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
sudo tee /etc/nginx/nginx.conf > /dev/null <<'EOF'
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 4096;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    include /etc/nginx/conf.d/*.conf;

    server {
        listen       80;
        listen       [::]:80;
        server_name  _;
        root         /usr/share/nginx/html;

        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html { }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html { }
    }

    server {
        listen       443 ssl http2;
        listen       [::]:443 ssl http2;
        server_name  terraform.devsecops.energy;
        root         /usr/share/nginx/html;

        ssl_certificate      /etc/pki/nginx/server.crt;
        ssl_certificate_key  /etc/pki/nginx/private/server.key;

        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html { }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html { }
    }
}
EOF

sudo cat > ~/server_rootCA.csr.cnf << EOF3
# server_rootCA.csr.cnf
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn

[dn]
C=US
ST=Virginia
L=Germantown
O=doe
OU=local_RootCA
emailAddress=terraform@devsecops.energy
CN = terraform.devsecops.energy
EOF3

sudo mkdir /etc/pki/nginx/private/
sudo chmod 700 /etc/pki/nginx/
sudo chmod 700 /etc/pki/nginx/private/
sudo openssl req -new -sha256 -nodes -out /etc/pki/nginx/server.csr -newkey rsa:2048 -keyout /etc/pki/nginx/private/server.key -config ~/server_rootCA.csr.cnf
sudo chmod 600 /etc/pki/nginx/private/server.key
sudo openssl x509 -signkey /etc/pki/nginx/private/server.key -in /etc/pki/nginx/server.csr -req -days 365 -out /etc/pki/nginx/server.crt
sudo chown -R nginx:nginx /usr/share/nginx/
sudo chown -R nginx:nginx /etc/pki/nginx/
sudo systemctl restart nginx