param(
    [Parameter(Mandatory=$true)]
    [string]$SitePort
)

Get-ChildItem 'configs' -Filter "$SitePort" -Directory |
Where-Object { $_.BaseName -match '^\d+$' } |
ForEach-Object {

    [string]$project_name = "shinystudio_$($_.BaseName)"

    Write-Host "*** Stopping $project_name"

    [string]$network_name = "$($project_name)_default"

    docker stop $(docker ps --filter "NETWORK=$network_name" -q)
    docker rm -f $(docker ps --filter "NETWORK=$network_name" -aq)

    $env:SITEPORT = $_.BaseName

    $env:CONTENTPATH = " "
    $env:USER = $env:USERNAME
    $env:USERID = 0
    $env:HTTPSPORT = 0

    docker-compose -p $project_name down
}
