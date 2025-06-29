## How to setup VPS with deployment hook attached

In a fresh new VPS, it is a bit challenging to set up everything from ground up.
Let's setup a VPS for laravel application with deployment hook attached.

I am writing this for ubuntu:24, you may need to tweak commands if you use different OS.

## If you don't have any user other than root

Most VPS provider will give you access to a user named `ubuntu`. If not, create a user named ubuntu using `adduser ubuntu` and make sure to add it to sudo group by `usermod -aG sudo ubuntu`. Now you can either log in to ubuntu or start shell as ubuntu by running `su ubuntu`

## If you are logged in as sudo user

Let's start setting Up

To update softwares and start installation

```sh
sudo apt update && sudo apt upgrade -y
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:ondrej/php
```

NOTE: replace 7.4 with your preferred php version

```sh
sudo apt install -y php7.4 php7.4-{cli,mysql,gd,opcache,fpm,bcmath,common,curl,gmp,imagick,imap,intl,mbstring,mysql,readline,xml,zip}
```

I am using nginx as web server and mysql as database

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
Now we have everything (nginx, mysql, composer and certbot) we need.

Let's create home for application. I usually use `/home/ubuntu/domains` directory to host all the applications. You can chose as you wish.

Let's create root for **example.com** and initialize git (with main branch) in it

```sh
mkdir -p ~/domains/example.com
cd ~/domains/example.com
git init --initial-branch=main
git config receive.denyCurrentBranch updateinstead
```

Now push your code to remote url
```sh
ubuntu@server-ip-or-domain:/home/ubuntu/domains/example.com
```
NOTE: make sure your ssh key is set up. if not, set up using `mkdir -p ~/.ssh && touch ~/.ssh/authorized_keys && nano ~/.ssh/authorized_keys` and paste your public key at the end.

Now push your code to server.

Now we need to configure the application and mysql user also.
Let's start with the server configuration.

To set up the web application for laravel
```sh
sudo nano /etc/nginx/sites-available/example.com.conf
```
Paste the below config (NOTE : make sure to replace example.com with your domain and php7.4 to your php version)
```
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

Now enable the domain using
```sh
sudo ln -s /etc/nginx/sites-available/example.com.conf /etc/nginx/sites-enabled/example.com.conf
sudo nginx -s reload
```

Now create a mysql user. To enter root mysql console `sudo myql`.
You will see cursor in **mysql>**
```mysql
CREATE DATABASE example;
CREATE USER example@localhost IDENTIFIED BY "SuperSecretPassword";
GRANT ALL PRIVILEGES ON example.* TO example@localhost;
FLUSH PRIVILEGES;
EXIT
```

Now set up the application
```sh
cd ~/domains/example.com
```

I prefer using the hook setup script. (Follow the interactive instruction)
```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/HazzazBinFaiz/laravel-git-hooks/main/initial_setup.sh)"
```

Now we just need to set up ssl (NOTE: replace webmaster@gmail.com with a valid mail for SSL security report. and replace domain)

```sh
sudo certbot --agree-tos --nginx -m webmaster@gmail.com  -d example.com
```

Enjoy 🥳
