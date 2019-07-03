#!/usr/bin/env bash
site_port="$1"
content_path="$2"

./controls/create.sh "$site_port"

re="^[0-9]+$"

for site_config in ./configs/*; do
    [ -d "$site_config" ] || continue

    SITEPORT=$(basename "$site_config")
    [[ $SITEPORT =~ $re ]] || continue
    [[ $SITEPORT == $site_port ]] || continue

    https_port=$(grep -oP "\s+listen\s+\K(\d+)\s+ssl;" "./configs/$SITEPORT/nginx.conf" | egrep -o "[0-9]+")

    if [ -z "$https_port" ]; then
        https_port=$((50000 + RANDOM % 10000))
        echo "No HTTPS port defined; using random high-port: ${https_port}"
    fi

    export SITEPORT
    export CONTENTPATH="$content_path"
    export USER
    export USERID=$UID
    export HTTPSPORT=$https_port

    docker-compose -p "shinystudio_${SITEPORT}" up -d --build --no-recreate
done
