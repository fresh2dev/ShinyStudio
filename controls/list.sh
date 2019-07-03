#!/usr/bin/env bash

site_port="$1"

re="^[0-9]+$"

for site_config in ./configs/*; do
    [ -d "$site_config" ] || continue

    SITEPORT=$(basename "$site_config")
    [[ $SITEPORT =~ $re ]] || continue
    [[ $SITEPORT == $site_port ]] || continue

    echo "$SITEPORT"
done
