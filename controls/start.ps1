
Get-ChildItem ".\sites\$($env:INSTANCEID)*.yml" | ForEach-Object {
    [string]$env:SITECONFIG = $_.FullName | Resolve-Path -Relative

    [uint16]$env:SITEPORT, [string]$env:SITEID = $_.BaseName.Split('_', 2)

    if (-not $env:SITEID) {
        $env:SITEID=$env:SITEPORT
    }

    if (-not (Test-Path $env:MOUNTPOINT)) {
        $null = New-Item $env:MOUNTPOINT -ItemType Directory -Force
    }

    $env:MOUNTPOINT = $env:MOUNTPOINT | Resolve-Path
    # '/host_mnt/c/Users/...'
    $env:MOUNTPOINT = '/host_mnt/' + ($env:MOUNTPOINT[0].ToString().ToLower() + $env:MOUNTPOINT.Substring(2).Replace('\', '/'))

    [string]$nginx_conf = "./configs/nginx/$($env:SITEPORT).conf"
    if (Test-Path $nginx_conf) {
        [string[]]$lines = Get-Content $nginx_conf
        foreach ($line in $lines) {
            if ($line -match "\s+listen\s+(\d+)\s+ssl;") {
                $env:SSLPORT = $Matches[1].ToString()
                break
            }
        }
        docker-compose.exe -p "shinystudio_$($env:SITEPORT)" up -d --build --no-recreate
    }
}
