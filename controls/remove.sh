#!/usr/bin/env bash

read -p "Permanently remove all images & containers at '${MOUNTPOINT}'?" -n 1 -r

if [[ $REPLY =~ ^[Yy]$ ]]
then
	source ./controls/stop.sh
	echo "*** Removing"
	docker-compose down -v
	docker rmi $(docker image ls --filter=reference='shinystudio*' -q)
fi
