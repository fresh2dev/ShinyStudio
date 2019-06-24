Write-Host "Permanently remove all ShinyStudio images & containers?"
Pause

Write-Host '*** Removing'
docker-compose.exe down
docker.exe rmi $(docker image ls --filter=reference='shinystudio*' -q)
