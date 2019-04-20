#!/usr/bin/env bash

# enter pyenv
source "${VIRTUAL_ENV}/bin/activate"

# setup $USER now
mv -f /etc/cont-init.d/userconf /tmp/userconf.sh
chmod +x /tmp/userconf.sh
source /tmp/userconf.sh

# Do this to ensure 'SHINYPROXY_USERNAME' and 'SHINYPROXY_GROUPS'
# are available in the rstudio user's environment.
env | grep "SHINYPROXY" > "/home/${USER}/.Renviron"

# setup .gitconfig for this user.
echo "[user]
    name = ${USER}
    email = none@none.com" > "/home/${USER}/.gitconfig"

# make shiny-examples available; read-only.
ln -sf /srv/shiny-server/ "/home/${USER}/shiny-examples"

if [ "$1" != "rstudio" ]; then
	# don't load rstudio; load shiny.
	sudo rm -rf /etc/services.d/rstudio
else
	# don't load shiny; load rstudio.
	sudo rm -rf /etc/services.d/shiny-server

	# if none exists, init git repo.
	site_path="/home/${USER}/__ShinyStudio__"
	if [ ! -d "${site_path}/.git" ]; then
		git init "${site_path}"
		chown -R $USER "${site_path}"
	fi
fi

/init
