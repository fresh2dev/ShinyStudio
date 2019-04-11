
read -p "Permanently remove all images, containers, content, and preferences at '${MOUNTPOINT}'?" -n 1 -r

if [[ $REPLY =~ ^[Yy]$ ]]
then
	source ./stop.sh
	echo "*** Removing"
	docker-compose down -v
	docker rmi $(docker image ls --filter=reference='shinystudio*' -q)
	sudo rm -rf "${MOUNTPOINT}"
fi
