# Generate RDP connection files
[CmdletBinding()]
param (
    $Fqdn,
    $Username,
    # $Password,
    $RdpFilename
)

Write-Host "PowerShell Version: $($PSVersionTable.PSVersion)"

Write-Host "Creating RDP file [$($RdpFilename).rdp] for [$Fqdn]..."

@"
full address:s:$($Fqdn):3389
prompt for credentials:i:0
username:s:$Username
password 51:b:$(("$env:VM_ADMIN_PASSWORD" | ConvertTo-SecureString -AsPlainText -Force) | ConvertFrom-SecureString)
"@ | Set-Content -Path "$($RdpFilename).rdp" -Force
