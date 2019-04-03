export SITEID=0
export SITEPORT=8080
export DESTSITE=8080

read -p "Permanently remove all content and preferences? " -n 1 -r

if [[ $REPLY =~ ^[Yy]$ ]]
then
	source ./stop.sh
	docker-compose down -v
	sudo rm -rf /srv/shiny-server
fi
