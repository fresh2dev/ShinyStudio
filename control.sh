#!/usr/bin/env bash

op="$1"
site_port="$2"
content_path="$3"

case "$op" in
    new)
        op=create
        ;;
    up)
        op=start
        ;;
    down)
        op=stop
        ;;
    setup)
        op=restart
        ;;
    ls)
        op=list
        ;;
    rm)
esac

op_script="./controls/${op}.sh"

if [ ! -f "${op_script}" ]; then
    echo "
./control.sh <operation> [<site port>] [<content path>]

Supported operations:

- start   (or 'up')
- stop    (or 'down')
- restart (or 'setup')
- create  (or 'new')
- list    (or 'ls')

Example:

# create and start site on port 8080.
./control.sh start 8080

# create config for port 8081; don't start.
./control.sh create 8081

# list all.
./control.sh ls

# stop all.
./control.sh stop

# start all.
./control.sh start
"
else
    
    if [ -z "$site_port" ]; then
        site_port='*'
    fi

    if [ -z "$content_path" ]; then
        content_path="${PWD}/content"
    fi

    "${op_script}" "$site_port" "$content_path"
fi
