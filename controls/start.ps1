param(
    [Parameter(Mandatory=$true)]
    [string]$SitePort,
    [Parameter(Mandatory=$true)]
    [string]$ContentPath
)

. ./controls/create.ps1 $SitePort

Get-ChildItem "configs" -Filter "$SitePort" -Directory |
Where-Object { $_.BaseName -match '^\d+$' } |
ForEach-Object {
    [uint16]$user_id = $UID

    if ($PSVersionTable.PSVersion.Major -lt 6 -or $IsWindows) {
        $user_id = 1000

        if (-not (Test-Path $ContentPath)) {
            $null = New-Item $ContentPath -ItemType Directory -Force
        }
        # ensure path is the full path, including drive letter.
        $ContentPath = ($ContentPath | Resolve-Path).Path
        # convert Windows path to Docker-friendly path
        # e.g., C:\Users/... ->'/host_mnt/c/Users/...'
        $ContentPath = '/host_mnt/' + ($ContentPath[0].ToString().ToLower() + $ContentPath.Substring(2).Replace('\', '/'))
    }
    
    [string]$https_port = $null
    [string[]]$lines = Get-Content $(Join-Path $_.FullName 'nginx.conf')
    foreach ($line in $lines) {
        if ($line -match "\s+listen\s+(\d+)\s+ssl;") {
            $https_port = [int]::Parse($Matches[1]).ToString()
            break
        }
    }

    if (-not $https_port) {
        $https_port = (Get-Random -Minimum 50000 -Maximum 60000).ToString()
        Write-Host "No HTTPS port defined in nginx.conf; using random high-port: ${https_port}"
    }

    $env:SITEPORT = $_.BaseName
    $env:CONTENTPATH = $ContentPath
    $env:USER = $env:USERNAME
    $env:USERID = $user_id
    $env:HTTPSPORT = $https_port

    docker-compose -p "shinystudio_$($env:SITEPORT)" up -d --build --no-recreate
}
