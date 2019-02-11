# Creates an Azure Service Principle for Terraform
# Vars
$servicePrincipleName = 'terraform'
$password = 'MyStrongPassw0rd!'
$resourceGroupName = 'terraform-mgmt-rg'
$location = 'eastus'
$storageAccountSku = 'Standard_LRS'

$randomPrefix = -join ((48..57) + (97..122) | Get-Random -Count 10 | ForEach-Object {[char]$_})
$vaultName = "$randomPrefix-terraform-kv"
$storageAccountName = "$($randomPrefix)terraform"
$storageContainerName = 'terraform-state'


#region New Terraform SP
$taskMessage = "Creating a Service Principle for Terraform"
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
$taskMessage = "Creating a new resource group for Terraform Management"
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
$taskMessage = "Creating KeyVault for Terraform login details"
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
$taskMessage = "Setting KeyVault Access Policy for Terraform SP"
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
$taskMessage = "Setting KeyVault Secrets for Terraform SP"
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
$taskMessage = "Creating a new Storage Account for Terraform backend state"
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
$taskMessage = "Creating a new Storage Container for Terraform State"
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

