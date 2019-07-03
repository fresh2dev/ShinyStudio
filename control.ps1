param(
    [ValidateSet('start', 'stop', 'restart', 'setup', 'up', 'down')]
    [string]$op,
    [string]$InstanceID,
    [string]$Mountpoint
)

[hashtable]$op_translate = @{
    'up'='start';
    'down'='stop';
    'setup'='restart'
}

if ($op_translate.Keys -contains $op) {
    $op = $op_translate[$op]
}

[string]$op_script = Join-Path 'controls' ($op + '.ps1')

if (-not (Test-Path $op_script))
{
    Write-Host "
./control.ps1 <operation> [<instance id>] [<mountpoint>]

Supported operations:

- start
- stop
- restart

Example:

./control.ps1 setup


"
}
else
{
    if (-not $Mountpoint) {
        $Mountpoint = Join-Path $PWD 'content'
    }

    $env:INSTANCEID = $InstanceID

    $env:MOUNTPOINT = $Mountpoint
    $env:USER = $env:USERNAME
    $env:USERID = 1000
    $env:SITECONFIG = ""
    $env:SITEID = 0
    $env:SSLPORT = Get-Random -Minimum 50000 -Maximum 60000

    . $op_script
}
