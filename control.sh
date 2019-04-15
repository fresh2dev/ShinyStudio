#!/usr/bin/env bash

MOUNTPOINT="/srv/shiny-server"

if [ ! -z "$2" ]; then
    MOUNTPOINT="$2"
fi

export MOUNTPOINT
export USER=$USER
export USERID=$UID
export SITEID=0         # placeholder to ensure successful build
export SITEPORT=8080    # placeholder to ensure successful build
export DESTSITE=8080    # placeholder to ensure successful build

source "./controls/$1.sh"
