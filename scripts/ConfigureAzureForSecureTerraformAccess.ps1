<#
.SYNOPSIS
    Configures Azure for secure Terraform access.
.DESCRIPTION
    Configures Azure for secure Terraform access using Azure Key Vault.

    The following steps are automated:
    - Creates an Azure Service Principle for Terraform.
    - Creates a new Resource Group.
    - Creates a new Storage Account.
    - Creates a new Storage Container.
    - Creates a new Key Vault.
    - Configures Key Vault Access Policies.
    - Creates Key Vault Secrets for these sensitive Terraform login details:
        - ARM_SUBSCRIPTION_ID
        - ARM_CLIENT_ID
        - ARM_CLIENT_SECRET
        - ARM_TENANT_ID
        - ARM_ACCESS_KEY
.NOTES
    Assumptions:
    - Azure PowerShell module is installed: https://docs.microsoft.com/en-us/powershell/azure/install-az-ps
    - Azure CLI is installed: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows
    - You are already logged into Azure before running this script (eg. Connect-AzAccount)

    Author:  Adam Rush
    Blog:    https://adamrushuk.github.io
    GitHub:  https://github.com/adamrushuk
    Twitter: @adamrushuk
#>


#region Variables
$adminUserDisplayName = 'Adam Rush' # This is used to assign yourself access to KeyVault
$servicePrincipleName = 'terraform'
$servicePrinciplePassword = 'MyStrongPassw0rd!'
$resourceGroupName = 'terraform-mgmt-rg'
$location = 'eastus'
$storageAccountSku = 'Standard_LRS'
$storageContainerName = 'terraform-state'

# Prepend random prefix with A character, as some resources cannot start with a number
$randomPrefix = "a" + -join ((48..57) + (97..122) | Get-Random -Count 8 | ForEach-Object {[char]$_})
$vaultName = "$randomPrefix-terraform-kv"
$storageAccountName = "$($randomPrefix)terraform"
#endregion Variables


#region New Terraform SP (Service Principal)
$taskMessage = "Creating Terraform Service Principle: [$servicePrincipleName] using Azure CLI"
Write-Host "STARTED: $taskMessage..."
try {
    az ad sp create-for-rbac --name $servicePrincipleName --password $servicePrinciplePassword
    $terraformSP = Get-AzADServicePrincipal -DisplayName  $servicePrincipleName -ErrorAction 'Stop'
} catch {
    Write-Error -Message "ERROR: $taskMessage." -ErrorAction 'Continue'
    throw $_
}
Write-Host "FINISHED: $taskMessage."
#endregion New Terraform SP (Service Principal)


#region Get Subscription
$taskMessage = "Finding Subscription and Tenant details"
Write-Host "STARTED: $taskMessage..."
try {
    $subscription = Get-AzSubscription -ErrorAction 'Stop'
} catch {
    Write-Error -Message "ERROR: $taskMessage." -ErrorAction 'Continue'
    throw $_
}
Write-Host "FINISHED: $taskMessage."
#endregion Get Subscription


#region New Resource Group
$taskMessage = "Creating Terraform Management Resource Group: [$resourceGroupName]"
Write-Host "STARTED: $taskMessage..."
try {
    $azResourceGroupParams = @{
        Name        = $resourceGroupName
        Location    = $location
        ErrorAction = 'Stop'
        Verbose     = $true
    }
    New-AzResourceGroup @azResourceGroupParams
} catch {
    Write-Error -Message "ERROR: $taskMessage." -ErrorAction 'Continue'
    throw $_
}
Write-Host "FINISHED: $taskMessage."
#endregion New Resource Group


#region New Storage Account
$taskMessage = "Creating Terraform backend Storage Account: [$storageAccountName]"
Write-Host "STARTED: $taskMessage..."
try {
    $azStorageAccountParams = @{
        ResourceGroupName = $resourceGroupName
        Location          = $location
        Name              = $storageAccountName
        SkuName           = $storageAccountSku
        Kind              = 'StorageV2'
        ErrorAction       = 'Stop'
        Verbose           = $true
    }
    $storageAccount = New-AzStorageAccount @azStorageAccountParams
} catch {
    Write-Error -Message "ERROR: $taskMessage." -ErrorAction 'Continue'
    throw $_
}
Write-Host "FINISHED: $taskMessage."
#endregion New Storage Account


#region Select Storage Container
$taskMessage = "Selecting Default Storage Account"
Write-Host "STARTED: $taskMessage..."
try {
    $azCurrentStorageAccountParams = @{
        ResourceGroupName = $resourceGroupName
        AccountName       = $storageAccountName
        ErrorAction       = 'Stop'
        Verbose           = $true
    }
    $currentStorageAccount = Set-AzCurrentStorageAccount @azCurrentStorageAccountParams
} catch {
    Write-Error -Message "ERROR: $taskMessage." -ErrorAction 'Continue'
    throw $_
}
Write-Host "FINISHED: $taskMessage."
#endregion Select Storage Account


#region New Storage Container
$taskMessage = "Creating Terraform State Storage Container: [$storageContainerName]"
Write-Host "STARTED: $taskMessage..."
try {
    $azStorageContainerParams = @{
        Name        = $storageContainerName
        Permission  = 'Off'
        ErrorAction = 'Stop'
        Verbose     = $true
    }
    $storageContainer = New-AzStorageContainer @azStorageContainerParams
} catch {
    Write-Error -Message "ERROR: $taskMessage." -ErrorAction 'Continue'
    throw $_
}
Write-Host "FINISHED: $taskMessage."
#endregion New Storage Container


#region New KeyVault
$taskMessage = "Creating Terraform KeyVault: [$vaultName]"
Write-Host "STARTED: $taskMessage..."
try {
    $azKeyVaultParams = @{
        VaultName         = $vaultName
        ResourceGroupName = $resourceGroupName
        Location          = $location
        ErrorAction       = 'Stop'
        Verbose           = $true
    }
    New-AzKeyVault @azKeyVaultParams
} catch {
    Write-Error -Message "ERROR: $taskMessage." -ErrorAction 'Continue'
    throw $_
}
Write-Host "FINISHED: $taskMessage."
#endregion New KeyVault


#region Set KeyVault Access Policy
$taskMessage = "Setting KeyVault Access Policy for Admin User: [$adminUserDisplayName]"
Write-Host "STARTED: $taskMessage..."
$adminADUser = Get-AzADUser -DisplayName $adminUserDisplayName
try {
    $azKeyVaultAccessPolicyParams = @{
        VaultName                 = $vaultName
        ResourceGroupName         = $resourceGroupName
        ObjectId                  = $adminADUser.Id
        PermissionsToKeys         = @('Get', 'List')
        PermissionsToSecrets      = @('Get', 'List', 'Set')
        PermissionsToCertificates = @('Get', 'List')
        ErrorAction               = 'Stop'
        Verbose                   = $true
    }
    Set-AzKeyVaultAccessPolicy @azKeyVaultAccessPolicyParams
} catch {
    Write-Error -Message "ERROR: $taskMessage." -ErrorAction 'Continue'
    throw $_
}
Write-Host "FINISHED: $taskMessage."

$taskMessage = "Setting KeyVault Access Policy for Terraform SP: [$servicePrincipleName]"
Write-Host "STARTED: $taskMessage..."
try {
    $azKeyVaultAccessPolicyParams = @{
        VaultName                 = $vaultName
        ResourceGroupName         = $resourceGroupName
        ObjectId                  = $terraformSP.Id
        PermissionsToKeys         = @('Get', 'List')
        PermissionsToSecrets      = @('Get', 'List', 'Set')
        PermissionsToCertificates = @('Get', 'List')
        ErrorAction               = 'Stop'
        Verbose                   = $true
    }
    Set-AzKeyVaultAccessPolicy @azKeyVaultAccessPolicyParams
} catch {
    Write-Error -Message "ERROR: $taskMessage." -ErrorAction 'Continue'
    throw $_
}
Write-Host "FINISHED: $taskMessage."
#endregion Set KeyVault Access Policy


#region Terraform login variables
# Get Storage Access Key
$storageAccessKeys = Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName -Name $storageAccountName
$storageAccessKey = $storageAccessKeys[0].Value # only need one of the keys

$terraformLoginVars = @{
    'ARM-SUBSCRIPTION-ID' = $subscription.Id
    'ARM-CLIENT-ID'       = $terraformSP.ApplicationId
    'ARM-CLIENT-SECRET'   = $servicePrinciplePassword
    'ARM-TENANT-ID'       = $subscription.TenantId
    'ARM-ACCESS-KEY'      = $storageAccessKey
}
Write-Host "`nTerraform login details:"
$terraformLoginVars | Out-String | Write-Host
#endregion Terraform login variables


#region Create KeyVault Secrets
$taskMessage = "Creating KeyVault Secrets for Terraform"
Write-Host "STARTED: $taskMessage..."
try {
    foreach ($terraformLoginVar in $terraformLoginVars.GetEnumerator()) {
        $AzKeyVaultSecretParams = @{
            VaultName   = $vaultName
            Name        = $terraformLoginVar.Key
            SecretValue = (ConvertTo-SecureString -String $terraformLoginVar.Value -AsPlainText -Force)
            ErrorAction = 'Stop'
            Verbose     = $true
        }
        $secret = Set-AzKeyVaultSecret @AzKeyVaultSecretParams
    }
} catch {
    Write-Error -Message "ERROR: $taskMessage." -ErrorAction 'Continue'
    throw $_
}
Write-Host "FINISHED: $taskMessage."
#endregion Create KeyVault Secrets
