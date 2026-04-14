#!/bin/bash
##########################################################
## Script to install and configure Nginx on AWS EC2     ##
## Amazon Linux 2023                                    ##
## - Installs nginx                                     ##
## - Generates a self-signed SSL certificate            ##
## - Configures HTTP (port 80) and HTTPS (port 443)     ##
## - All output is logged to /var/log/user-data.log     ##
##########################################################

set -euxo pipefail

#####################
### User Data Log ###
#####################
## Everything this script does gets written to this log file.
## To view it after launch: sudo cat /var/log/user-data.log
exec > >(tee /var/log/user-data.log | logger -t user-data) 2>&1

#########################################
### Get This Instance's Public IP     ###
### from the EC2 Metadata Service     ###
#########################################
## 169.254.169.254 is a special internal AWS address always available on EC2 instances
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
echo "Public IP is: ${PUBLIC_IP}"

#####################
### Update System ###
#####################
sudo dnf -y update
sudo dnf -y upgrade

#########################
### Install Firewalld ###
#########################
## Firewalld is a host-based firewall that runs inside the OS.
## The AWS Security Group is the cloud-level firewall outside the instance.
## Both layers work together.
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

#########################################
### Create SSL Certificate Directories ###
#########################################
sudo mkdir -p /etc/pki/nginx/private/
sudo chmod 700 /etc/pki/nginx/
sudo chmod 700 /etc/pki/nginx/private/

#############################################
### Generate Self-Signed SSL Certificate  ###
#############################################
## This creates a certificate for the server's public IP address.
## Browsers will show a security warning because it is not signed by a
## trusted Certificate Authority (CA).  That is expected for this lab.
## In production you would use Let's Encrypt or AWS Certificate Manager.
sudo openssl req -new -sha256 -nodes \
  -newkey rsa:2048 \
  -keyout /etc/pki/nginx/private/server.key \
  -out /etc/pki/nginx/server.csr \
  -subj "/C=US/ST=Virginia/L=Reston/O=TerraformClass/CN=${PUBLIC_IP}"

sudo openssl x509 -signkey /etc/pki/nginx/private/server.key \
  -in /etc/pki/nginx/server.csr \
  -req -days 365 \
  -out /etc/pki/nginx/server.crt

sudo chmod 600 /etc/pki/nginx/private/server.key

###############################
### Create Custom Index Page ###
###############################
sudo mv /usr/share/nginx/html/index.html /usr/share/nginx/html/index.html.bak

## Note: Using unquoted EOF so ${PUBLIC_IP} variable expands into the HTML
sudo tee /usr/share/nginx/html/index.html > /dev/null << EOF
<html>
  <head>
    <title>Terraform Nginx Lab</title>
    <style>
      body  { font-family: Arial, sans-serif; max-width: 700px; margin: 80px auto; text-align: center; background: #f4f4f4; }
      h1    { color: #232F3E; }
      p     { color: #555; font-size: 1.1em; }
      .ip   { font-size: 1.4em; font-weight: bold; color: #FF9900; }
      .box  { background: white; border-radius: 8px; padding: 30px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
    </style>
  </head>
  <body>
    <div class="box">
      <h1>You deployed this with Terraform!</h1>
      <p>This server is running <strong>Nginx</strong> on <strong>Amazon Linux 2023</strong></p>
      <p>Public IP: <span class="ip">${PUBLIC_IP}</span></p>
      <p>HTTP  (port 80)  &#10003; enabled</p>
      <p>HTTPS (port 443) &#10003; enabled (self-signed certificate)</p>
    </div>
  </body>
</html>
EOF

#######################
### Configure Nginx ###
#######################
## Back up the original config before replacing it
sudo mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak

## Note: Using quoted 'NGINXEOF' so nginx variables like $remote_addr are NOT expanded by bash
sudo tee /etc/nginx/nginx.conf > /dev/null << 'NGINXEOF'
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

    ## HTTP server block (port 80)
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

    ## HTTPS server block (port 443)
    server {
        listen       443 ssl http2;
        listen       [::]:443 ssl http2;
        server_name  _;
        root         /usr/share/nginx/html;

        ssl_certificate      /etc/pki/nginx/server.crt;
        ssl_certificate_key  /etc/pki/nginx/private/server.key;

        ssl_protocols  TLSv1.2 TLSv1.3;
        ssl_ciphers    HIGH:!aNULL:!MD5;

        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html { }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html { }
    }
}
NGINXEOF

####################################
### Fix Permissions and Restart  ###
####################################
sudo chown -R nginx:nginx /usr/share/nginx/
sudo chown -R nginx:nginx /etc/pki/nginx/
sudo systemctl restart nginx

echo "Nginx setup complete. HTTP and HTTPS are now active."
