export SITEID=0
export SITEPORT=8080
export DESTSITE=8080

for site_config in ./shinyproxy/config/sites/*.yml; do
    [ -e "$site_config" ] || continue

	SITEID=$(basename "$site_config" .yml)
	SITEPORT=$(echo $SITEID | cut -d '_' -f1)
	DESTSITE=$(echo $SITEID | cut -d '_' -f2)

	echo "$SITEID --> $SITEPORT --> $DESTSITE"

	if [ ! -d "/srv/shiny-server/${DESTSITE}" ]; then
		mkdir "/srv/shiny-server/${DESTSITE}" 
		cp -R ./content/* "/srv/shiny-server/${DESTSITE}"
		mv "/srv/shiny-server/${DESTSITE}/git" "/srv/shiny-server/${DESTSITE}/.git"
	fi

	docker-compose run -d --service-ports -e SITEID=$SITEID -e DESTSITE=$DESTSITE shinyproxy
done
