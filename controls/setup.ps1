#!/usr/bin/env bash

. ./controls/stop.ps1

Write-Host "*** Building"

docker-compose.exe build

. ./controls/start.ps1
