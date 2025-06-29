# How to Set Up a VPS with a Deployment Hook

Setting up a fresh VPS can be challenging, especially when starting from scratch. Let’s set up a VPS for a Laravel application with an attached deployment hook.

I am writing this guide for Ubuntu 24.04; you may need to tweak the commands if you are using a different operating system.

---

## If You Don’t Have Any User Other Than Root

Most VPS providers grant access to a user named `ubuntu`. If not, create a user named `ubuntu` using the following command:

```sh
adduser ubuntu
```

Add this user to the sudo group:

```sh
usermod -aG sudo ubuntu
```

Now, you can either log in as `ubuntu` or start a shell session as `ubuntu` by running:

```sh
su ubuntu
```

---

## If You Are Logged In as a Sudo User

Let’s start setting up your VPS.

### Update Software and Install Necessary Packages

```sh
sudo apt update && sudo apt upgrade -y
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:ondrej/php
```

> **NOTE:** Replace `7.4` with your preferred PHP version.

```sh
sudo apt install -y php7.4 php7.4-{cli,mysql,gd,opcache,fpm,bcmath,common,curl,gmp,imagick,imap,intl,mbstring,mysql,readline,xml,zip}
```

### Install Nginx, MySQL, and Other Tools

```sh
sudo apt install -y nginx mysql-server
sudo systemctl enable mysql
sudo systemctl enable nginx
sudo usermod -aG ubuntu www-data
sudo usermod -aG www-data ubuntu
sudo systemctl restart nginx
sudo systemctl restart php*

php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php
php -r "unlink('composer-setup.php');"
sudo mv composer.phar /usr/local/bin/composer

sudo snap install core
sudo snap refresh core
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
```

Now we have everything we need: Nginx, MySQL, Composer, and Certbot.

---

## Set Up the Application Directory

I usually use `/home/ubuntu/domains` to host all applications. You can choose any directory you prefer. Create a root directory for **example.com** and initialize a Git repository:

```sh
mkdir -p ~/domains/example.com
cd ~/domains/example.com
git init --initial-branch=main
git config receive.denyCurrentBranch updateInstead
```

Now push your code to the remote URL:

```sh
ubuntu@server-ip-or-domain:/home/ubuntu/domains/example.com
```

> **NOTE:** Ensure your SSH key is set up. If not, set it up using:

```sh
mkdir -p ~/.ssh && touch ~/.ssh/authorized_keys && nano ~/.ssh/authorized_keys
```

Paste your public key at the end of the file.

---

## Configure the Server

### Set Up the Web Application for Laravel

Open a new Nginx configuration file:

```sh
sudo nano /etc/nginx/sites-available/example.com.conf
```

Paste the following configuration (replace `example.com` with your domain and `php7.4` with your PHP version):

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name example.com;
    root /home/ubuntu/domains/example.com/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ ^/index\.php(/|$) {
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_hide_header X-Powered-By;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

Enable the domain configuration:

```sh
sudo ln -s /etc/nginx/sites-available/example.com.conf /etc/nginx/sites-enabled/example.com.conf
sudo nginx -s reload
```

### Create a MySQL User

To access the MySQL root console, run:

```sh
sudo mysql
```

Inside the MySQL prompt:

```mysql
CREATE DATABASE example;
CREATE USER 'example'@'localhost' IDENTIFIED BY 'SuperSecretPassword';
GRANT ALL PRIVILEGES ON example.* TO 'example'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

---

## Set Up the Application

Navigate to the application directory:

```sh
cd ~/domains/example.com
```

Use the hook setup script to configure your application (follow the interactive instructions):

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/HazzazBinFaiz/laravel-git-hooks/main/initial_setup.sh)"
```

---

## Set Up SSL

> Before setting up SSL, ensure your DNS records are properly configured and have successfully propagated. You can verify this by checking your domain’s A and AAAA (for ipv6) records point to your server’s IP address.

To set up SSL, run:

```sh
sudo certbot --agree-tos --nginx -m webmaster@gmail.com -d example.com
```

> **NOTE:** Replace `webmaster@gmail.com` with a valid email address for SSL security reports and `example.com` with your actual domain.

---

Enjoy your fully configured Laravel application! 🥳
