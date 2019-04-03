export SITEID=0
export SITEPORT=8080
export DESTSITE=8080

docker stop $(docker ps --filter "NETWORK=shinystudio-net" -q)
docker rm -f $(docker ps --filter "NETWORK=shinystudio-net" -aq)
docker-compose down
