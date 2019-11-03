[cmdletbinding()]
param (
    [string[]]$Templates,
    [string]$CloudInit = 'cloud-init.yml',
    [Alias('Get')]
    [switch]$Info,
    [Alias('New')]
    [switch]$Create,
    [Alias('Restart')]
    [switch]$Reboot,
    [Alias('Remove')]
    [switch]$Destroy,
    [Alias('Enter')]
    [switch]$SSH,
    [Alias('h')]
    [switch]$Help,
    [switch]$Force
)

begin {
    $ErrorActionPreference = 'Stop'

    [string]$notice = @"
Digital Ocean charges money for utilized resources.
This script is provided as-is with no warranty or liability of any kind.
"@

    Write-Verbose $notice

    if (-not $Templates) {
        $Templates = Get-ChildItem 'templates' -File -Filter '*.env' |
                        Select-Object -ExpandProperty FullName
    }

    if (([bool]$Info + [bool]$Create + [bool]$Reboot + [bool]$Destroy + [bool]$SSH) -gt 1) {
        Write-Error 'Only one action supported per call.'
    }

    function log {
        param (
            [string]$Message,
            [switch]$NoNewline
        )

        Write-Host $((Get-Date).ToLongTimeString() + ': ' + $Message) -NoNewline:$NoNewline
    }

    function Read-TemplateVars {
        param (
            [string]$Template
        )

        Get-Content $Template |
            Where-Object { -not $_.StartsWith('#') -and $_.IndexOf('=') -gt 1 } |
                ForEach-Object -Begin {$t=@{}} -Process {$k,$v=$_.Split('=',2); $t[$k]=$v} -End {$t}
    }

    function Write-TemplateVar {
        param (
            [string]$Template,
            [string]$Key,
            [string]$Value
        )

        [string[]]$lines = @(Get-Content $Template |
                            ForEach-Object {
                                if (-not $_.StartsWith('#') -and $_.StartsWith($Key+'=')) {
                                    '{0}={1}' -f $Key, $Value
                                }
                                else {
                                    $_
                                }
                            })

        $lines | Out-File $Template -Force

        [string]$template_name = Split-Path $Template -Leaf

        log "Updated template '$template_name': $Key --> $Value"
    }


    function request {
        param (
            [string]$Path,
            [object]$Body,
            [string]$Method = 'Get',
            [string]$BaseUri = 'https://api.digitalocean.com/v2',
            [switch]$Force,
            [int]$ExpectedResponse
        )

        [string]$BodyAsJson = $null

        if ($Body) {
            $BodyAsJson = $Body | ConvertTo-Json
            $Method = 'Post'
        }

        [string]$uri = "$BaseUri/$Path"

        if ($Method -eq 'Post' -and -not $Force) {
            log "POST: '$uri'"
            log $('parameters: ' + $BodyAsJson)
            if (-not $Force) {
                $null = confirm -Prompt "Create new '$Path' resource with above parameters?"
            }
        }

        $resp = Invoke-WebRequest -Uri $uri -Method $Method `
            -Body $BodyAsJson `
            -Headers @{
            'Content-Type'  = 'application/json';
            'Authorization' = "Bearer $script:token"
            }

        Write-Verbose "Response: $($resp)"

        if ($ExpectedResponse -and $resp.StatusCode -ne $ExpectedResponse) {
            Write-Error "HTTP response '$($resp.StatusCode)' is not the expected '$ExpectedResponse'."
        }
            
        $resp.Content | ConvertFrom-Json
    }

    function confirm {
        [cmdletbinding()]
        param (
            [string]$Message = '',
            [string]$Prompt  = 'Continue?'
        )

        if ($Message) {
            log $Message
        }

        [string]$yn = Read-Host -Prompt $($Prompt +  ' (y/n)')

        $proceed = $($yn -in ('y', 'yes'))

        if (-not $proceed) {
            Write-Error 'Cancelled by user.'
        }

        return $proceed
    }

    function Prompt-IfNull {
        param(
            [hashtable]$vars,
            [string[]]$keys
        )

        foreach ($k in $keys) {
            if (-not $vars[$k]) {
                $v = Read-Host -Prompt "Provide a value for '$k': "
                if (-not $v) {
                    Write-Error 'Aborting operation.'
                }
                else {
                    $vars[$k] = $v
                    Write-TemplateVar -Template $script:Template -Key $k -Value $v
                }
            }
        }

        $vars
    }

    function Get-FloatingIp {
        param (
            [string]$ip
        )

        (request 'floating_ips').floating_ips |
            Where-Object ip -eq $ip
    }

    function New-FloatingIp {
        param (
            [string]$ip,
            [string]$region,
            [switch]$Force
        )

        (request 'floating_ips' -Body @{'region'=$region} -Force:$Force).floating_ip
    }

    function Get-EbsVolume {
        [cmdletbinding()]
        param (
            [string]$name
        )

        [object]$volume = (request 'volumes').volumes |
                            Where-Object { $_.Name -eq $name }

        if (-not $volume) {
            Write-Error "No volume with name '$name'."
        }

        $volume
    }

    function New-EbsVolume {
        param (
            [string]$name,
            [string]$region,
            [switch]$Force
        )

        (request 'volumes' -Force:$Force -Body @{
            "size_gigabytes" = 10;
            "name" = $name;
            "description" = "";
            "region" = $region;
            "filesystem_type" = "ext4";
            "filesystem_label" = $name
        }).volume
    }

    function Get-SshKeys {
        [cmdletbinding()]
        param (
            [string]$filter = '*'
        )

        [object[]]$ssh_keys = (request 'account/keys').ssh_keys |
                        Where-Object { $_.name -like $filter }

        if (-not $ssh_keys) {
            Write-Error "No SSH key names match filter '$filter'."
        }

        $ssh_keys
    }

    function Set-SshKey {
        param (
            [string]$name,
            [string]$public_key_file = '~/.ssh/id_rsa.pub',
            [switch]$Force
        )

        if (-not $name -or $name -eq '*') {
            $name = [System.Environment]::MachineName
        }

        $public_key_file = $public_key_file | Resolve-Path

        if (-not (Test-Path $public_key_file)) {
            Write-Error "Cannot upload SSH public key; File not found: '$public_key_file'. Create one with 'ssh-keygen'."
        }

        (request 'account/keys' -Force:$Force -Body @{
            'name'=$name;
            'public_key'=[string]$(Get-Content $public_key_file -Raw);
            }).ssh_key
    }

    function Get-Droplet {
        [cmdletbinding()]
        param (
            [string]$name
        )

        [object]$droplet = (request 'droplets').droplets |
                            Where-Object name -eq $name

        if (-not $droplet) {
            Write-Error "No droplet with name '$name'."
        }

        $droplet
    }

    function Get-DropletStatus {
        param (
            [object]$droplet
        )

        if (-not $droplet) {
            'non-existent'
        }
        else {
            $droplet.status
        }
    }

    function New-Droplet {
        param (
            [string]$name,
            [string]$region,
            [string]$size,
            [string]$image,
            [string[]]$ssh_keys,
            [string]$userdata,
            [string]$volume_id
        )

        [hashtable]$body = @{
            "name"      = $Name;
            "region"    = $Region;
            "size"      = $Size;
            "image"     = $Image;
            "ssh_keys"  = $ssh_keys;
            "backups"   = $false;
            "ipv6"      = $false;
            "monitoring"= $false;
            "user_data" = $userdata;
            "volumes"   = @($volume_id)
            "private_networking" = $false;
        }
        
        (request 'droplets' -Body $body -Force:$Force).droplet
    }

    function Start-DropletAction {
        param (
            [string]$droplet_id,
            [ValidateSet('reboot','shutdown')]
            [string]$ActionType,
            [switch]$Force
        )

        if (-not $Force) {
            $null = confirm -Message "This will $ActionType Droplet with id: $droplet_id"
        }

        (request "droplets/$droplet_id/actions" -Body @{'type'=$ActionType} -Force).action
    }

    function Remove-Droplet {
        [cmdletbinding()]
        param (
            [string]$droplet_id,
            [switch]$Force
        )

        if (-not $Force) {
            $null = confirm -Message "This will destroy Droplet with id: $droplet_id"
        }
        
        (request "droplets/$droplet_id" -Method 'DELETE' -ExpectedResponse 204)
    }

    function Load-UserData {
        param (
            [string]$file,
            [string]$volume,
            [string]$repo,
            [string]$branch,
            [string]$domain,
            [string]$user,
            [string]$email
        )

        [hashtable]$template = @{
            'user'   = '<UserName>';
            'volume' = '<VolumeName>';
            'repo'   = '<Repo>';
            'branch' = '<Branch>';
            'domain' = '<DomainName>';
            'email'  = '<EmailAddress>';
        }

        [string]$userdata = Get-Content $CloudInit -Raw

        foreach ($key in $template.Keys) {
            if ($userdata.Contains($template[$key])) {
                $value = (Get-Variable -Name $key).Value
                $userdata = $userdata.Replace($template[$key], $value)
            }
        }

        $userdata
    }

    function Get-DropletActions {
        param (
            [string]$droplet_id
        )

        (request "droplets/$droplet_id/actions").actions
    }

    function Wait-Action {
        param (
            [Parameter(ValueFromPipeline=$true)]
            [object[]]$action
        )

        process {
            foreach ($a in $action) {
                do {
                    if ($a.status -eq 'in-progress') {
                        Start-Sleep -Seconds 3
                        log "Waiting for '$($a.type)' action '$($a.id)' to complete."
                    }
                    $a = (request "actions/$($a.id)").action
                } while ($a.status -eq 'in-progress')

                log "'$($a.type)' action '$($a.id)' finished with status '$($a.status)'."

                $a
            }
        }
    }

    function Set-FloatingIp {
        param (
            [string]$ip,
            [string]$droplet_id
        )

        (request "floating_ips/$ip/actions" -Force -Body @{
            'type' = 'assign';
            'droplet_id' = $droplet_id
        }).action
    }

    function Remove-SshKnownHost {
        param (
            [string]$ip,
            [string]$known_hosts_file = "~/.ssh/known_hosts"
        )

        $known_hosts_file = $known_hosts_file | Resolve-Path    

        & ssh-keygen -f "$known_hosts_file" -R "$ip"
    }

    function Test-HTTP {
        param (
            [string]$Uri,
            [switch]$Quiet
        )

        [int]$resp_code = -1

        try {
            $resp_code = (Invoke-WebRequest -Uri $Uri -SkipCertificateCheck -TimeoutSec 3 -EA Stop).StatusCode
        }
        catch {
            $resp_code = $_.Exception.Response.StatusCode.value__
        }

        if (-not $Quiet) {
            if (-not $resp_code) {
                log "HTTP Response from '$Uri': NULL"
            }
            else {
                log "HTTP Response from '$Uri': $($resp_code.ToString())"
            }
        }

        $resp_code
    }

    function Wait-HTTPStatus {
        param (
            [string]$Uri,
            [int[]]$StatusCode
        )

        do {
            $resp_code = Test-HTTP $Uri
            if ($resp_code -notin $StatusCode) {
                Start-Sleep -Seconds 3
            }
        } while ($resp_code -notin $StatusCode)

        $resp_code
    }

    function Wait-Offline {
        param (
            [string]$ip
        )

        [bool]$online = $true

        while($online)
        {
            $online = Test-Connection $ip -Count 1 -Quiet

            log "IP address '$ip': " -NoNewline

            if ($online) {
                Write-Host 'online'
                Start-Sleep -Seconds 3
            }
            else {
                Write-Host 'offline'
            }
        } 
    }
}
###################################

process {
    foreach ($Template in $Templates) {
        Write-Host ''
        
        if (-not (Test-Path $Template)) {
            if ([System.IO.Path]::GetExtension($Template) -ne '.env') {
                $Template += '.env'
            }
            [string]$fq_Template = Join-Path 'templates' $Template
            if (-not (Test-Path $fq_Template)) {
                Write-Error "Template file not found: '$Template'"
            }
            else {
                $Template = $fq_Template
            }
        }

        $script:Template = $Template | Resolve-Path

        [string]$template_name = Split-Path $Template -Leaf

        Write-Host "*** Template: '$template_name'"


        [hashtable]$vars = Read-TemplateVars $script:Template

        $vars = Prompt-IfNull $vars -keys 'Token', 'DropletName'

        if (-not $vars['VolumeName']) {
            $vars['VolumeName'] = $vars['DropletName']
        }

        [string]$script:token = $vars['Token']

        if ($Create) {
            if (-not (Test-Path $CloudInit)) {
                Write-Error "Cloud-Init file not found: '$CloudInit'"
            }

            if (-not ($vars['UserName'])) {
                $vars['UserName'] = [environment]::UserName
                Write-TemplateVar $script:Template -Key 'UserName' -Value $vars['UserName']
            }

            if (-not $vars['Branch']) {
                $vars['Branch'] = 'master'
                Write-TemplateVar $script:Template -Key 'Branch' -Value $vars['Branch']
            }

            $vars = Prompt-IfNull $vars -keys 'Region','Size','Image','Repo'

            [object]$droplet = Get-Droplet $vars['DropletName'] -EA 0

            log "Droplet '$($vars['DropletName'])': $(Get-DropletStatus $droplet)"

            if ($droplet) {
                Write-Error "Droplet '$($vars['DropletName'])' already exists."
            }

            if (-not $vars['FloatingIp']) {
                $vars['FloatingIp'] = Read-Host 'Floating IP ("x.x.x.x", leave empty to create one): '
            }
            
            [object]$float_ip = $null

            if (-not $vars['FloatingIp']) {
                $float_ip = New-FloatingIp $vars['FloatingIp'] $vars['Region'] -Force:$Force
                $vars['FloatingIp'] = $float_ip.ip
                Write-TemplateVar -Template $script:Template -Key 'FloatingIp' -Value $vars['FloatingIp']
            }
            else {
                $float_ip = Get-FloatingIp $vars['FloatingIp'] -EA 0
            }    

            if ($float_ip.droplet) {
                Write-Error "Floating IP '$($vars['FloatingIp'])' is already assigned."
            }

            [object]$volume = Get-EbsVolume $vars['VolumeName'] -EA 0

            if (-not $volume) {
                $volume = New-EbsVolume $vars['VolumeName'] $vars['Region'] -Force:$Force
            }

            if ($volume.droplet.Count -gt 0) {
                Write-Error "Volume '$($vars['VolumeName'])' is already assigned."
            }

            [array]$ssh_keys = Get-SshKeys -filter $vars['SshKeyName'] -EA 0

            if (-not $ssh_keys) {
                $ssh_keys = Set-SshKey $vars['SshKeyName']
            }

            log "SSH keys: $($ssh_keys.name -join ', ')"

            if (-not $vars['DomainName']) {
                $vars['DomainName'] = $vars['FloatingIp']
            }

            [string]$userdata = Load-UserData $CloudInit -repo $vars['Repo'] -volume $vars['VolumeName'] -branch $vars['Branch'] -domain $vars['DomainName'] -user $vars['UserName'] -email $vars['EmailAddress']

            [object]$droplet = New-Droplet -name $vars['DropletName'] -region $vars['Region'] `
                                    -size $vars['Size'] -image $vars['Image'] -ssh_keys $ssh_keys.id `
                                    -volume_id $volume.id -userdata $userdata -Force:$Force

            $null = Get-DropletActions $droplet.id | Wait-Action

            $null = Set-FloatingIp $vars['FloatingIp'] $droplet.id | Wait-Action

            log "Access your Droplet with:"
            log "ssh $($vars['UserName'])@$($vars['FloatingIp'])"

            if (-not $Force) {
                $proceed = confirm -Prompt 'Wait for HTTP access (~5 minutes)?' -EA 0

                if ($proceed) {
                    $null = Wait-HTTPStatus -Uri "http://$($vars['FloatingIp'])" -StatusCode 200,301,302
                }

                $proceed = confirm -Prompt 'Enter SSH now?' -EA 0

                if ($proceed) {
                    Start-Sleep -Seconds 5
                    & ssh "$($vars['UserName'])@$($vars['FloatingIp'])"
                }
            }
        }
        elseif ($Destroy) {
            $vars = Prompt-IfNull $vars -keys 'FloatingIp'

            Remove-SshKnownHost $vars['FloatingIp']

            [object]$droplet = Get-Droplet $vars['DropletName'] -EA Stop

            $null = Start-DropletAction $droplet.id -ActionType 'shutdown' -Force:$Force | Wait-Action

            $null = Wait-Offline $vars['FloatingIp']
            
            Remove-Droplet $droplet.id -Force:$Force -EA Stop

            log 'Destroyed Droplet.'
            log 'Note: this operation does not remove volumes or floating IPs.'
        }
        elseif ($Reboot) {
            [object]$droplet = Get-Droplet $vars['DropletName'] -EA Stop

            $droplet

            $null = Start-DropletAction $droplet.id -ActionType 'reboot' -Force:$Force | Wait-Action

            if (-not $Force) {
                [bool]$proceed = confirm -Prompt 'Wait for HTTP access?' -EA 0

                if ($proceed) {
                    $vars = Prompt-IfNull $vars -keys 'FloatingIp'
                    Start-Sleep -Seconds 5
                    $null = Wait-HTTPStatus -Uri "http://$($vars['FloatingIp'])" -StatusCode 200,301,302
                }
            }
        }
        elseif ($SSH) {
            $vars = Prompt-IfNull $vars -keys 'UserName', 'FloatingIp'

            [object]$droplet = Get-Droplet $vars['DropletName'] -EA Stop

            & ssh "$($vars['UserName'])@$($vars['FloatingIp'])"
        }
        elseif ($Help) {
            Write-Host @"
Supported actions:
- Info    (Get)
- Create  (New)
- SSH     (Enter)
- Reboot  (Restart)
- Destroy (Remove)
"@
        }
        else { # elseif ($Info) {
            $vars = Prompt-IfNull $vars -keys 'FloatingIp', 'VolumeName'

            [string]$status = $null

            [object]$volume = Get-EbsVolume $vars['VolumeName'] -EA 0

            log "Volume '$($vars['VolumeName'])': " -NoNewline

            if (-not $volume) {
                Write-Host 'non-existent' -ForegroundColor Red
            }
            elseif ($volume.droplet_ids.Count -gt 0) {
                Write-Host 'attached' -ForegroundColor Green
            }
            else {
                Write-Host 'detached' -ForegroundColor Yellow
            }

            [object]$float_ip = Get-FloatingIp $vars['FloatingIp'] -EA 0

            log "Floating IP '$($vars['FloatingIp'])': " -NoNewline

            if (-not $float_ip) {
                Write-Host 'non-existent' -ForegroundColor Red
            }
            elseif ($float_ip.droplet) {
                Write-Host 'attached' -ForegroundColor Green
            }
            else {
                Write-Host 'detached' -ForegroundColor Yellow
            }

            [object]$droplet = Get-Droplet $vars['DropletName'] -EA 0

            log "Droplet '$($vars['DropletName'])': " -NoNewline

            $status = Get-DropletStatus $droplet

            if ($status -eq 'non-existent') {
                Write-Host $status -ForegroundColor Red
            }
            else {
                Write-Host $status -ForegroundColor Green
            
                # only perform HTTP check if droplet exists.
                $uri = "http://$($vars['FloatingIp'])"
                [int]$http_code = Test-HTTP -Uri $uri -Quiet

                log "HTTP Response from '$uri': " -NoNewline

                if (-not $http_code) {
                    Write-Host 'NULL' -ForegroundColor Red
                }
                elseif ($http_code -notin @(200, 301, 302)) {
                    Write-Host $http_code -ForegroundColor Yellow
                }
                else {
                    Write-Host $http_code -ForegroundColor Green
                }
            }
        }
    }
}