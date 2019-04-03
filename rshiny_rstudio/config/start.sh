#!/usr/bin/env bash

# Do this to ensure 'SHINYPROXY_USERNAME' and 'SHINYPROXY_GROUPS'
# are available in the rstudio user's environment.
echo "[user]
        name = ${SHINYPROXY_USERNAME}
        email = none@none.com" > "/home/rstudio/.gitconfig"
env | grep "SHINYPROXY" > "/home/rstudio/.Renviron"

if [ "$1" != "rstudio" ]; then
	# don't load rstudio; load shiny.
	sudo rm -rf /etc/services.d/rstudio
else
	# don't load shiny; load rstudio.
	sudo rm -rf /etc/services.d/shiny-server
fi

/init
