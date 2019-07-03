param(
    [Parameter(Mandatory=$true)]
    [string]$ContentPath,
    [Parameter(Mandatory=$true)]
    [string]$SitePort
)

. ./controls/stop.ps1 $SitePort

. ./controls/start.ps1 $SitePort $ContentPath
