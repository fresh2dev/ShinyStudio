#!/usr/bin/env bash

Domain='example.com'
Email=""
Staging=0

if [ ! -z "$1" ]; then
    Domain="$1"

    if [ ! -z "$2" ]; then
        Email="$2"
    fi

    if [ "$2" == 1 ]; then
        Staging=1
    fi
fi

certbot_run() {
    docker-compose run --rm --entrypoint "/bin/sh -c" certbot "$1"
}

certbot_run "\
apk update && \
apk add curl && \
curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/tls_configs/options-ssl-nginx.conf > /etc/letsencrypt/options-ssl-nginx.conf && \
curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/ssl-dhparams.pem > /etc/letsencrypt/ssl-dhparams.pem"

certbot_run "\
rm -rf /etc/letsencrypt/live/$Domain && \
rm -rf /etc/letsencrypt/archive/$Domain && \
rm -rf /etc/letsencrypt/renewal/$Domain.conf
mkdir -p /etc/letsencrypt/live/$Domain && \
mkdir -p /etc/letsencrypt/archive/$Domain && \
mkdir -p /etc/letsencrypt/renewal/$Domain.conf"

certbot_run "\
openssl req -x509 -nodes -newkey rsa:1024 -days 365 \
    -keyout '/etc/letsencrypt/live/$Domain/privkey.pem' \
    -out '/etc/letsencrypt/live/$Domain/fullchain.pem' \
    -subj '/CN=$Domain'"

if [ ! -z "$Email" ]; then
    docker-compose up --force-recreate -d nginx

    certbot_run "\
    rm -rf /etc/letsencrypt/live/$Domain &&
    rm -rf /etc/letsencrypt/archive/$Domain && \
    rm -rf /etc/letsencrypt/renewal/$Domain.conf"

    domain_args="-d $Domain"

    email_arg="--email $Email"

    staging_arg=""
    if [ "$Staging" == "1" ]; then
        staging_arg='--staging'
    fi

    certbot_run "\
    certbot certonly --webroot -w /var/www/certbot \
        $staging_arg \
        $email_arg \
        $domain_args \
        --rsa-key-size 4096 \
        --agree-tos \
        --force-renewal"
fi

docker-compose up -d --no-recreate

docker-compose exec nginx nginx -s reload
