#!/usr/bin/env bash

MOUNTPOINT="${PWD}/content"

op_script="./controls/$1.sh"

if [ ! -f "${op_script}" ]; then
    echo "
./control.sh <operation>

Supported operations:

- setup
- update
- start
- stop
- restart
- remove

Example:

./control.sh setup
"
else
    if [ ! -z "$2" ]; then
        MOUNTPOINT="$2"
    fi

    export MOUNTPOINT
    export USER=$USER
    export USERID=$USERID
    export SITECONFIG=      # placeholder to suppress unnecessary warnings

    source "${op_script}"
fi