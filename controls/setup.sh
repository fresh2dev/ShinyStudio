#!/usr/bin/env bash

source ./controls/stop.sh

echo "*** Building"

docker-compose build

source ./controls/start.sh
