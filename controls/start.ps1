Get-ChildItem ".\sites\*.yml" | ForEach-Object {
    [string]$env:SITECONFIG = $_.FullName | Resolve-Path -Relative

    [string[]]$tmp = $_.BaseName.Split('_', 2)
    [uint16]$env:SITEPORT = $tmp[0]
    [string]$env:SITEID = $tmp[1]

    if (-not $env:SITEID) {
        $env:SITEID=$env:SITEPORT
    }

    if (-not (Test-Path $env:MOUNTPOINT)) {
        $null = New-Item $env:MOUNTPOINT -ItemType Directory -Force
    }

    $env:MOUNTPOINT = $env:MOUNTPOINT | Resolve-Path
    # '/host_mnt/c/Users/...'
    $env:MOUNTPOINT = '/host_mnt/' + ($env:MOUNTPOINT[0].ToString().ToLower() + $env:MOUNTPOINT.Substring(2).Replace('\', '/'))

    docker-compose.exe run --name "shinyproxy_$env:SITEPORT" -d `
        -p "$($env:SITEPORT):8080" `
        -e SITECONFIG="$env:SITECONFIG" `
        -e SITEID=$env:SITEID `
        -e MOUNTPOINT="$env:MOUNTPOINT" `
        -e USER=$env:USER `
        -e USERID=$env:USERID `
        myshinystudio
}
