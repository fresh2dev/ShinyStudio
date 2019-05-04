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

# set non-standard port for Jupyter notebook, for use in VS code.
mkdir -p "/home/${USER}/.jupyter"

echo "c.NotebookApp.ip = '127.0.0.1'
c.NotebookApp.port = 12345
c.NotebookApp.port_retries = 50
c.NotebookApp.token = ''
c.NotebookApp.open_browser = False
c.NotebookApp.disable_check_xsrf = True" > "/home/${USER}/.jupyter/jupyter_notebook_config.py"


# setup .gitconfig for this user.
echo "[user]
    name = ${USER}
    email = none@none.com" > "/home/${USER}/.gitconfig"

# make shiny-examples available; read-only.
ln -sf /srv/shiny-server/ "/home/${USER}/shiny-examples"

# parse arg $1 to define service to run (default: shiny-server)
svc="$1"

if [ -z "$svc" ]; then
    svc='shiny-server'
fi

find /etc/services.d/* -type d -not -name "$svc" | xargs rm -rf

# fix permissions
# chown -R $USERID:$USERID "/home/${USER}"

/init
