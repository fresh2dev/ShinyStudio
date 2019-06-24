Write-Host "*** Stopping"

docker.exe stop $(docker.exe ps --filter "NETWORK=shinystudio-net" -q)
docker.exe rm -f $(docker.exe ps --filter "NETWORK=shinystudio-net" -aq)
docker-compose.exe down
