#!/usr/bin/env bash

source ./controls/stop.sh

echo "*** Building"

docker-compose build

if [ ! -d "${MOUNTPOINT}" ]; then
	sudo mkdir -p \
		"${MOUNTPOINT}/content/sites" \
		"${MOUNTPOINT}/content/users" \
		"${MOUNTPOINT}/logs" \
		"${MOUNTPOINT}/settings/rstudio" \
		"${MOUNTPOINT}/settings/vscode"
fi

sudo chown -R $USER "${MOUNTPOINT}"

source ./controls/start.sh
