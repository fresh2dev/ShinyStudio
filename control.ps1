param(
    [ValidateSet('setup', 'start', 'stop', 'restart', 'update')]
    [string]$op,
    [string]$MOUNTPOINT = $(Join-Path $PWD 'content')
)

[string]$op_script = Join-Path 'controls' ($op + '.ps1')

if (-not (Test-Path $op_script))
{
    Write-Host "
./control.ps1 <operation> [<mountpoint>]

Supported operations:

- setup
- update
- start
- stop
- restart
- remove

Example:

./control.ps1 setup


"
}
else
{
    # export MOUNTPOINT
    # export USER=$USER
    # export USERID=$USERID
    # export SITECONFIG=      # placeholder to suppress unnecessary warnings

    $env:MOUNTPOINT = $MOUNTPOINT
    $env:USER = $env:USERNAME
    $env:USERID = 1000
    $env:SITECONFIG = ""

    . $op_script
}