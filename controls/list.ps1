param(
    [Parameter(Mandatory=$true)]
    [string]$SitePort
)

Get-ChildItem 'configs' -Filter "$SitePort" -Directory |
Where-Object { $_.BaseName -match '^\d+$' } |
Select-Object -ExpandProperty BaseName
