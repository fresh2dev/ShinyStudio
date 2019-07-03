param(
    [ValidateSet('create', 'new', 'start', 'stop', 'restart', 'setup', 'up', 'down', 'remove', 'rm', 'list', 'ls')]
    [string]$op,
    [string]$SitePort = '*',
    [string]$ContentPath = $(Join-Path $PWD 'content')
)

[hashtable]$op_translate = @{
    'new'   = 'create';
    'up'    = 'start';
    'down'  = 'stop';
    'setup' = 'restart';
    'ls'    = 'list';
    'rm'    = 'remove';
}

if ($op_translate.Keys -contains $op) {
    $op = $op_translate[$op]
}

[string]$op_script = Join-Path 'controls' ($op + '.ps1')

if (-not (Test-Path $op_script))
{
    Write-Host "
./control.ps1 <operation> [<site port>] [<content path>]

Supported operations:

- start   (or 'up')
- stop    (or 'down')
- restart (or 'setup')
- create  (or 'new')
- list    (or 'ls')

Example:

# create and start site on port 8080.
./control.ps1 start 8080

# create config for port 8081; don't start.
./control.ps1 create 8081

# list all.
./control.ps1 ls

# stop all.
./control.ps1 stop

# start all.
./control.ps1 start
"
}
else
{
    [hashtable]$params = @{
        'SitePort'=$SitePort
    }

    if (@('start', 'restart') -contains $op) {
        if (-not $ContentPath) {
            $ContentPath = Join-Path $PWD 'content'
        }

        $params.Add('ContentPath', $ContentPath)
    }

    . $op_script @params
}
