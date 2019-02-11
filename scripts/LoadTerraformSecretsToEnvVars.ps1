# Sets local session environment variables
# Assumes you are already logged into Azure

# Get Azure objects before KeyVault lookup
$tfKeyVault = Get-AzKeyVault | Where-Object VaultName -match 'terraform-kv'

# Get Azure KeyVault Secrets
$envVars = @{
    ARM_SUBSCRIPTION_ID = (Get-AzKeyVaultSecret -vaultName $tfKeyVault.VaultName -name 'ARM-SUBSCRIPTION-ID').SecretValueText
    ARM_CLIENT_ID       = (Get-AzKeyVaultSecret -vaultName $tfKeyVault.VaultName -name 'ARM-CLIENT-ID').SecretValueText
    ARM_CLIENT_SECRET   = (Get-AzKeyVaultSecret -vaultName $tfKeyVault.VaultName -name 'ARM-CLIENT-SECRET').SecretValueText
    ARM_TENANT_ID       = (Get-AzKeyVaultSecret -vaultName $tfKeyVault.VaultName -name 'ARM-TENANT-ID').SecretValueText
}

# Loads Terraform environment variables into current PowerShell session
Write-Host "Setting session environment variables for Azure / Terraform"
foreach ($envVar in $envVars.GetEnumerator()) {
    Write-Host "Setting [$($envVar.Key)] environment variables just for this session"
    Set-Item -Path "env:$($envVar.Key)" -Value $envVar.Value
}
