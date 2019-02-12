# Sets local session environment variables
# Assumes you are already logged into Azure (eg. Connect-AzAccount)

# Get Azure objects before KeyVault lookup
Write-Host "Searching for Terraform KeyVault..." -NoNewline
$tfKeyVault = Get-AzKeyVault | Where-Object VaultName -match 'terraform-kv'
Write-Host "SUCCESS!" -ForegroundColor 'Green'

# Get Azure KeyVault Secrets
Write-Host "Retrieving Terraform secrets from KeyVault..." -NoNewline
$envVars = @{
    ARM_SUBSCRIPTION_ID = (Get-AzKeyVaultSecret -vaultName $tfKeyVault.VaultName -name 'ARM-SUBSCRIPTION-ID').SecretValueText
    ARM_CLIENT_ID       = (Get-AzKeyVaultSecret -vaultName $tfKeyVault.VaultName -name 'ARM-CLIENT-ID').SecretValueText
    ARM_CLIENT_SECRET   = (Get-AzKeyVaultSecret -vaultName $tfKeyVault.VaultName -name 'ARM-CLIENT-SECRET').SecretValueText
    ARM_TENANT_ID       = (Get-AzKeyVaultSecret -vaultName $tfKeyVault.VaultName -name 'ARM-TENANT-ID').SecretValueText
    ARM_ACCESS_KEY      = (Get-AzKeyVaultSecret -vaultName $tfKeyVault.VaultName -name 'ARM-ACCESS-KEY').SecretValueText
}
Write-Host "SUCCESS!" -ForegroundColor 'Green'

# Loads Terraform environment variables into current PowerShell session
Write-Host "`nSetting session environment variables for Azure / Terraform:"
foreach ($envVar in $envVars.GetEnumerator()) {
    Write-Host "Setting [$($envVar.Key)]..." -NoNewline
    Set-Item -Path "env:$($envVar.Key)" -Value $envVar.Value
    Write-Host "SUCCESS!" -ForegroundColor 'Green'
}

Write-Host "`nFinished loading Terraform environment variables just for this PowerShell session" -ForegroundColor 'Green'
