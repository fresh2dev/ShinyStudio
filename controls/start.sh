#!/usr/bin/env bash

for SITECONFIG in ./sites/*.yml; do
    [ -e "$SITECONFIG" ] || continue

    BASENAME=$(basename "$SITECONFIG" .yml)
    SITEPORT=$(echo $BASENAME | cut -d '_' -f1)
    SITEID=$(echo $BASENAME | cut -d '_' -f2,3,4,5)

    if [ -z "$SITEID" ]; then
        SITEID=$SITEPORT
    fi

    docker-compose run --name "shinyproxy_${SITEPORT}" -d \
        -p $SITEPORT:8080 \
        -e SITECONFIG="$SITECONFIG" \
        -e SITEID=$SITEID \
        -e MOUNTPOINT="$MOUNTPOINT" \
        -e USER=$USER \
        -e USERID=$USERID \
        myshinystudio
done
