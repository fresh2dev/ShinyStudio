#!/usr/bin/env bash

site_port="$1"

dst="./configs/$site_port"

re="^[0-9]+$"

if [[ ! $site_port =~ $re ]]; then
    echo "Site folder must be named with an integer specifying the broadcast port."
elif [ ! -d "$dst" ]; then
    cp -R 'configs/template' "$dst"
    echo "Created site config at: '$dst'"
fi
