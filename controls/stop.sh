#!/usr/bin/env bash

echo "*** Stopping"

docker stop $(docker ps --filter "NETWORK=shinystudio-net" -q)
docker rm -f $(docker ps --filter "NETWORK=shinystudio-net" -aq)
docker-compose down
