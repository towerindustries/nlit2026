# User Data and Nginx with HTTPS

## What is User Data?

**User data** (sometimes called "user init") is a script you provide to an EC2 instance
that runs automatically **one time on first boot**.

AWS passes your script to a service called **cloud-init** which runs it as root before
the instance is fully up.  You can use it to:

- Install software packages
- Configure services
- Download files from S3
- Set up users or SSH keys
- Do basically anything a bash script can do

---

## Why This Matters

Without user data you would have to:
1. Launch the instance
2. SSH in
3. Manually run `dnf install nginx`
4. Configure nginx
5. Generate SSL certificates
6. Restart nginx

With user data, **all of that happens automatically** every time you deploy.
This is the power of infrastructure as code -- your server configuration is repeatable and documented.

---

## Create the Script Directory and File

```
mkdir -p /opt/lab_env/scripts
touch /opt/lab_env/scripts/nginx_https_install.sh
```

---

## The Full Script

Paste this content into `scripts/nginx_https_install.sh`:

```bash
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

## Everything this script does gets written to this log file.
## To view it after launch:  sudo cat /var/log/user-data.log
exec > >(tee /var/log/user-data.log | logger -t user-data) 2>&1

## Get This Instance's Public IP from the EC2 Metadata Service
## 169.254.169.254 is a special internal AWS address always available on EC2
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
echo "Public IP is: ${PUBLIC_IP}"

## Update the system packages
sudo dnf -y update
sudo dnf -y upgrade

## Install and enable the host-based firewall
sudo dnf -y install firewalld
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --zone=public --permanent --add-service=ssh
sudo firewall-cmd --zone=public --permanent --add-service=http
sudo firewall-cmd --zone=public --permanent --add-service=https
sudo firewall-cmd --reload

## Install and start nginx
sudo dnf -y install nginx
sudo systemctl enable --now nginx

## Create directories for the SSL certificate
sudo mkdir -p /etc/pki/nginx/private/
sudo chmod 700 /etc/pki/nginx/
sudo chmod 700 /etc/pki/nginx/private/

## Generate a self-signed SSL certificate using the server's public IP
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

## Replace the default index.html with a custom page
sudo mv /usr/share/nginx/html/index.html /usr/share/nginx/html/index.html.bak

sudo tee /usr/share/nginx/html/index.html > /dev/null << EOF
<html>
  <head><title>Terraform Nginx Lab</title></head>
  <body>
    <h1>You deployed this with Terraform!</h1>
    <p>Running Nginx on Amazon Linux 2023</p>
    <p>Public IP: ${PUBLIC_IP}</p>
    <p>HTTP (80) and HTTPS (443) are both enabled.</p>
  </body>
</html>
EOF

## Replace the nginx configuration to enable both HTTP and HTTPS
sudo mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak

sudo tee /etc/nginx/nginx.conf > /dev/null << 'NGINXEOF'
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;
include /usr/share/nginx/modules/*.conf;
events { worker_connections 1024; }
http {
    access_log /var/log/nginx/access.log;
    sendfile on;
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    server {
        listen 80;
        listen [::]:80;
        server_name _;
        root /usr/share/nginx/html;
    }

    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name _;
        root /usr/share/nginx/html;
        ssl_certificate     /etc/pki/nginx/server.crt;
        ssl_certificate_key /etc/pki/nginx/private/server.key;
        ssl_protocols       TLSv1.2 TLSv1.3;
        ssl_ciphers         HIGH:!aNULL:!MD5;
    }
}
NGINXEOF

sudo chown -R nginx:nginx /usr/share/nginx/
sudo chown -R nginx:nginx /etc/pki/nginx/
sudo systemctl restart nginx

echo "Nginx setup complete. HTTP and HTTPS are now active."
```

---

## Script Walkthrough

### `set -euxo pipefail`
Safety flags for the script:
- `-e` : Exit immediately if any command fails
- `-u` : Error if an undefined variable is used
- `-x` : Print each command before running it (visible in the log)
- `-o pipefail` : If any command in a pipeline fails, the whole pipeline fails

### Logging
```bash
exec > >(tee /var/log/user-data.log | logger -t user-data) 2>&1
```
Everything the script prints gets written to `/var/log/user-data.log`.
After your instance launches you can SSH in and read this file to verify the script ran correctly.

### Getting the Public IP
```bash
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
```
`169.254.169.254` is AWS's **Instance Metadata Service (IMDS)**.
It is a special IP address only accessible from within an EC2 instance.
You can query it to get information about the instance without any credentials.

### SSL Certificate Generation
```bash
sudo openssl req -new -sha256 -nodes \
  -newkey rsa:2048 \
  -keyout /etc/pki/nginx/private/server.key \
  -out /etc/pki/nginx/server.csr \
  -subj "/C=US/.../CN=${PUBLIC_IP}"

sudo openssl x509 -signkey ... -req -days 365 -out /etc/pki/nginx/server.crt
```
This generates a **self-signed certificate** -- a certificate you sign yourself rather than
getting signed by a trusted Certificate Authority like Let's Encrypt or DigiCert.

| File | Purpose |
|------|---------|
| `server.key` | Private key -- kept secret on the server |
| `server.csr` | Certificate signing request -- intermediate file |
| `server.crt` | The certificate -- installed into nginx |

> **Browser warning expected:** When you visit `https://YOUR_IP` in a browser, you will see
> a security warning like "Your connection is not private."
> This is normal for self-signed certificates.  Click **Advanced** → **Proceed anyway**.
> In production, you would use AWS Certificate Manager or Let's Encrypt for trusted certificates.

### Heredoc Syntax -- Important

The script uses two types of heredoc:

**Unquoted `<< EOF`** -- bash variables EXPAND inside
```bash
sudo tee index.html << EOF
<p>IP: ${PUBLIC_IP}</p>   ← ${PUBLIC_IP} becomes the real IP
EOF
```

**Quoted `<< 'NGINXEOF'`** -- bash variables do NOT expand inside
```bash
sudo tee nginx.conf << 'NGINXEOF'
log_format main '$remote_addr ...';  ← $remote_addr stays as literal text
NGINXEOF
```
Nginx uses `$variable` syntax in its config.  Using a quoted heredoc prevents bash from
interpreting those as bash variables and expanding them incorrectly.

---

## Viewing the Log After Launch

Once your instance is running, SSH in and check the log:

```
ssh -i dev-example-key.pem ec2-user@YOUR_PUBLIC_IP
sudo cat /var/log/user-data.log
```

Look for the last line:
```
Nginx setup complete. HTTP and HTTPS are now active.
```

If you see errors, the `-x` flag means every command is logged before it runs,
so you can see exactly which step failed.

---

## AWS Console: User Data

You can view the user data that was passed to an instance:

```
EC2 → Instances → (select your instance) → Actions → Instance Settings → Edit user data
```

> **Screenshot:** A modal window shows the raw content of your user data script.
> Note that it is read-only after launch -- you cannot change user data on a running instance.

---

**Next:** [09 - Outputs](09-outputs.md)
