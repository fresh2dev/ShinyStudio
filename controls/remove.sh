
read -p "Permanently remove all content and preferences at '${MOUNTPOINT}'?" -n 1 -r

if [[ $REPLY =~ ^[Yy]$ ]]
then
	source ./stop.sh
	echo "*** Removing"
	docker-compose down -v
	rm -rf "${MOUNTPOINT}/*"
fi
