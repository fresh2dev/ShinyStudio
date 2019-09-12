param (
    [string[]]$DomainName = @('example.com'),
    [string]$Email,
    [switch]$Staging,
    [uint32]$RSA_Key_Size = 4096
)

function certbot_run($cmd) {
    docker-compose run --rm --entrypoint "/bin/sh -c" certbot $cmd
}

$domain = $DomainName[0]

certbot_run "\
apk update && \
apk add curl && \
curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/tls_configs/options-ssl-nginx.conf > /etc/letsencrypt/options-ssl-nginx.conf && \
curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/ssl-dhparams.pem > /etc/letsencrypt/ssl-dhparams.pem"

certbot_run "\
mkdir -p /etc/letsencrypt/live/$domain && \
mkdir -p /etc/letsencrypt/archive/$domain && \
mkdir -p /etc/letsencrypt/renewal/$domain.conf"

certbot_run "\
openssl req -x509 -nodes -newkey rsa:1024 -days 365 \
    -keyout '/etc/letsencrypt/live/$domain/privkey.pem' \
    -out '/etc/letsencrypt/live/$domain/fullchain.pem' \
    -subj '/CN=$domain'"

if ($Email) {
    docker-compose up --force-recreate -d nginx

    certbot_run "\
    rm -rf /etc/letsencrypt/live/$domain &&
    rm -rf /etc/letsencrypt/archive/$domain && \
    rm -rf /etc/letsencrypt/renewal/$domain.conf"

    [string]$domain_args = '-d ' + $($DomainName -join ' -d ')

    $email_arg = "--email $Email"

    $staging_arg = ''
    if ($Staging) {
        $staging_arg = '--staging'
    }

    certbot_run "\
    certbot certonly --webroot -w /var/www/certbot \
        $staging_arg \
        $email_arg \
        $domain_args \
        --rsa-key-size $RSA_Key_Size \
        --agree-tos \
        --force-renewal"
}

docker-compose up -d --no-recreate

docker-compose exec nginx nginx -s reload
