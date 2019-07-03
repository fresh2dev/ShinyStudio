param(
    [Parameter(Mandatory=$true)]
    [string]$SitePort
)

[string]$dst = Join-Path 'configs' $SitePort.ToString()

if ($SitePort -notmatch '^\d+$') {
    Write-Host "Site folder must be named with an integer specifying the broadcast port."
}
elseif (-not (Test-Path $dst -PathType Container)) {
    [string]$src = Join-Path 'configs' 'template'
    $null = Copy-Item $src $dst -Container -Recurse -Force
    Write-Host "Created site config at: '$dst'"
}
