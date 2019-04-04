source ./stop.sh

echo "*** Building"

docker-compose build --force-rm

if [ ! -d "${MOUNTPOINT}" ]; then
	sudo mkdir -p "${MOUNTPOINT}"
fi

sudo chown -R $USER "${MOUNTPOINT}"

source ./start.sh
