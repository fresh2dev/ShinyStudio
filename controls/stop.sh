#!/usr/bin/env bash

site_port="$1"

re="^[0-9]+$"

for site_config in ./configs/*; do
    [ -d "$site_config" ] || continue

    SITEPORT=$(basename "$site_config")
    [[ $SITEPORT =~ $re ]] || continue
    [[ $SITEPORT == $site_port ]] || continue

    project_name="shinystudio_${SITEPORT}"

    echo "*** Stopping ${project_name}"

    network_name="${project_name}_default"

    docker stop $(docker ps --filter "NETWORK=$network_name" -q)
    docker rm -f $(docker ps --filter "NETWORK=$network_name" -aq)

    export SITEPORT

    export CONTENTPATH=" "
    export USER
    export USERID=$UID
    export HTTPSPORT=0

    docker-compose -p "${project_name}" down
done
