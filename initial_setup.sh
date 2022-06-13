#!/bin/bash

set -e

read -r -p "Setup app (Y/N) : " SETUP
if [ "$SETUP" != 'Y' ]; then
    exit 0
fi

read -r -p "App name : " APP_NAME
read -r -p "App ENV (local/production/..): " APP_ENV
read -r -p "App Debug (true/false): " APP_DEBUG
read -r -p "App URL (https://...com): " APP_URL
APP_URL="${APP_URL//\//\\/}"
read -r -p "DB_DATABASE : " DB_DATABASE
read -r -p "DB_USERNAME : " DB_USERNAME
read -r -p "DB_PASSWORD : " DB_PASSWORD

FILE_NAME='.env'

cp .env.example $FILE_NAME

sed -i "s/APP_NAME=.*/APP_NAME=\"$APP_NAME\"/" $FILE_NAME
sed -i "s/APP_ENV=.*/APP_ENV=$APP_ENV/" $FILE_NAME
sed -i "s/APP_DEBUG=.*/APP_DEBUG=$APP_DEBUG/" $FILE_NAME
sed -i "s/APP_URL=.*/APP_URL=\"$APP_URL\"/" $FILE_NAME
sed -i "s/DB_DATABASE=.*/DB_DATABASE=\"$DB_DATABASE\"/" $FILE_NAME
sed -i "s/DB_USERNAME=.*/DB_USERNAME=\"$DB_USERNAME\"/" $FILE_NAME
sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=\"$DB_PASSWORD\"/" $FILE_NAME


read -r -p "Install Deploy on push hook (Y/N) : " HOOK
if [ "$HOOK" = 'Y' ]; then
    curl https://raw.githubusercontent.com/HazzazBinFaiz/laravel-git-hooks/main/post-receive >.git/hooks/post-receive
fi

composer install -o --no-dev
php artisan key:generate
php artisan storage:link
php artisan migrate --force --seed
php artisan optimize
php artisan up
