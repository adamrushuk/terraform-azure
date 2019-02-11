# Creates an Azure Service Principle for Terraform
# Vars
$adminUserDisplayName = 'Adam Rush' # This is used to assign yourself access to KeyVault
$servicePrincipleName = 'terraform'
$password = 'MyStrongPassw0rd!'
$resourceGroupName = 'terraform-mgmt-rg'
$location = 'eastus'
$storageAccountSku = 'Standard_LRS'
$storageContainerName = 'terraform-state'

# Prepend random prefix with A character, as some resources cannot start with a number
$randomPrefix = "a" + -join ((48..57) + (97..122) | Get-Random -Count 8 | ForEach-Object {[char]$_})
$vaultName = "$randomPrefix-terraform-kv"
$storageAccountName = "$($randomPrefix)terraform"


#region New Terraform SP
$taskMessage = "Creating Terraform Service Principle: [$servicePrincipleName]"
Write-Host "STARTED: $taskMessage..."
try {
    $azADApplicationParams = @{
        DisplayName    = $servicePrincipleName
        IdentifierUris = "http://$($servicePrincipleName)"
        Password       = (ConvertTo-SecureString $password -AsPlainText -Force)
        ErrorAction    = 'Stop'
        Verbose        = $true
    }
    $terraformSP = New-AzADApplication @azADApplicationParams
} catch {
    Write-Error -Message "ERROR: $taskMessage." -ErrorAction 'Continue'
    throw $_
}
Write-Host "FINISHED: $taskMessage."
#endregion New Terraform SP


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


# Combine Terraform login variables
$terraformLoginVars = @{
    'ARM-SUBSCRIPTION-ID' = $subscription.Id
    'ARM-CLIENT-ID'       = $terraformSP.ApplicationId
    'ARM-CLIENT-SECRET'   = $password
    'ARM-TENANT-ID'       = $subscription.TenantId
}
Write-Host "`nTerraform login details:"
$terraformLoginVars | Out-String | Write-Host


#region New resource group
$taskMessage = "Creating Terraform Management resource group: [$resourceGroupName]"
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
#endregion New resource group


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
        ObjectId                  = $terraformSP.ObjectId
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


#region Account Storage Container
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
