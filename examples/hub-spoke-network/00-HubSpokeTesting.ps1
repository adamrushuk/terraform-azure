# Hub-spoke network TF build testing
# Navigate to example folder
cd examples\hub-spoke-network

<# Configure Service Principle and Azure Key Vault first time only
..\..\scripts\ConfigureAzureForSecureTerraformAccess.ps1 -adminUserDisplayName 'Adam Rush'
#>

# Create and load env vars
..\..\scripts\LoadAzureTerraformSecretsToEnvVars.ps1

# Run Terraform
terraform init
terraform plan | sls "resource"
..\..\scripts\Invoke-Terraform.ps1 -Command "apply"

# Redisplay outputs
terraform output
terraform show


# TODO - Validate connectivity


# Destroy
..\..\scripts\Invoke-Terraform.ps1 -Command "destroy"
