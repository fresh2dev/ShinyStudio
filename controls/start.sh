#!/usr/bin/env bash

for site_config in ./shinyproxy/config/sites/*.yml; do
	[ -e "$site_config" ] || continue

	SITEID=$(basename "$site_config" .yml)
	SITEPORT=$(echo $SITEID | cut -d '_' -f1)
	DESTSITE=$(echo $SITEID | cut -d '_' -f2)

	SITEDIR="${MOUNTPOINT}/content/sites/${DESTSITE}"

	echo "*** Starting"

	if [ ! -d "$SITEDIR" ]; then
		mkdir -p "$SITEDIR"
		cp -RT "./content" "$SITEDIR"
	fi

	docker-compose run -d --service-ports -e SITEID=$SITEID -e DESTSITE=$DESTSITE -e MOUNTPOINT="$MOUNTPOINT" shinyproxy
done
