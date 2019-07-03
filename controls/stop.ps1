# if (-not $env:INSTANCEID) {
#     docker.exe stop $(docker.exe ps --filter "NETWORK=shinystudio" -a -q)
#     docker.exe rm -f $(docker.exe ps --filter="NETWORK=shinystudio" -aq)
# }

Get-ChildItem ".\sites\$env:INSTANCEID*.yml" | ForEach-Object {
    [string]$env:SITECONFIG = $_.FullName | Resolve-Path -Relative

    [uint16]$env:SITEPORT, [string]$env:SITEID = $_.BaseName.Split('_', 2)

    Write-Host "*** Stopping $($_.BaseName)"

    if (-not $env:SITEID) {
        $env:SITEID=$env:SITEPORT
    }

    #if ($env:INSTANCEID) {
    docker.exe stop $(docker.exe ps --filter "NETWORK=shinystudio_$($env:SITEPORT)_default" -q)
    docker.exe rm -f $(docker.exe ps --filter "NETWORK=shinystudio_$($env:SITEPORT)_default" -aq)
    #}

    docker-compose.exe -p "shinystudio_$($env:SITEPORT)" down
}
