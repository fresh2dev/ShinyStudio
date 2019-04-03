export SITEID=0
export SITEPORT=8080
export DESTSITE=8080

if [ "$1" == "--remove" ]; then
	source ./remove.sh
fi

source ./stop.sh

docker-compose build --force-rm

if [ ! -d "/srv/shiny-server" ]; then
	sudo mkdir -p /srv/shiny-server
	sudo chown ${USER} /srv/shiny-server
fi

source ./start.sh

# sudo chmod -R 777 /srv/shiny-server

