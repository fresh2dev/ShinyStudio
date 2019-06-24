#!/usr/bin/env bash

read -p "Permanently remove all ShinyStudio images & containers?" -n 1 -r

if [[ $REPLY =~ ^[Yy]$ ]]
then
	source ./controls/stop.sh
	echo "*** Removing"
	docker-compose down
	docker rmi $(docker image ls --filter=reference='shinystudio*' -q)
fi
