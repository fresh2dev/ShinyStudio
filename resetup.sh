
if [ "$1" == "remove" ]; then
    ./control.sh remove
    docker image prune -f
else
    ./control.sh stop
fi

sudo rm -rf /srv/shiny-server

docker volume prune -f

./control.sh setup
