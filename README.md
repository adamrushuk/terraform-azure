# Terraform Azure

## Purpose

Test secure **Azure** provisioning using **Terraform**,
utilising a [Remote Backend](https://www.terraform.io/docs/backends/types/azurerm.html) and a
[Key Vault](https://azure.microsoft.com/en-gb/services/key-vault/) in Azure.

> HashiCorp Terraform enables you to safely and predictably create, change, and improve infrastructure.
> It is an open source tool that codifies APIs into declarative configuration files that can be shared amongst
> team members, treated as code, edited, reviewed, and versioned.

## Preparation

Before you can securely use Terraform with Azure, you will need to action the following steps:

### Install Azure Dependencies / Log in to Azure

1. [Install the Azure PowerShell module](https://docs.microsoft.com/en-us/powershell/azure/install-az-ps).
1. [Install the Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows).
1. Ensure you are logged in to Azure (eg. `Connect-AzAccount`, `az login`)

### Configure Azure for Secure Terraform Access

1. Clone this repo: `git clone git@github.com:adamrushuk/terraform-azure.git`
1. Open `scripts\ConfigureAzureForSecureTerraformAccess.ps1` and update the `$adminUserDisplayName` variable to
match your Admin User Display Name (eg. `Joe Bloggs`).
1. Run `scripts\ConfigureAzureForSecureTerraformAccess.ps1`

The `ConfigureAzureForSecureTerraformAccess.ps1` script does the following:

1. Creates an Azure Service Principle for Terraform.
1. Creates a new Resource Group.
1. Creates a new Storage Account.
1. Creates a new Storage Container.
1. Creates a new Key Vault.
1. Configures Key Vault Access Policies.
1. Creates Key Vault Secrets for these sensitive Terraform login details:
     - ARM_SUBSCRIPTION_ID
     - ARM_CLIENT_ID
     - ARM_CLIENT_SECRET
     - ARM_TENANT_ID
     - ARM_ACCESS_KEY

### Load Azure Key Vault secrets into Terraform environment variables

Now that Azure has been configured for secure Terraform access, the Key Vault secrets need to be loaded into
environment variables, but only for the current PowerShell session.

1. Run `scripts\LoadAzureTerraformSecretsToEnvVars.ps1`

### Install Terraform

Either [download Terraform and add to your path](https://learn.hashicorp.com/terraform/getting-started/install.html)
, or use the Chocolatey method below:

1. [Install Chocolatey](https://chocolatey.org/docs/installation)
1. Install Terraform: `choco install terraform`

## Provisioning

Now that Terraform is installed, the secure remote backend can be utilised whilst provisioning an Azure Resource Group and a Virtual Network:

1. Navigate to the `examples\remote-backend\` folder.
1. Open `main.tf` and ensure you have updated the `storage_account_name` variable in the `backend` code block, to the new Storage Account Name created by the `ConfigureAzureForSecureTerraformAccess.ps1` script.
1. Initialise the Remote Backend and download plugins: `terraform init`
1. Create an execution plan (see planned changes): `terraform plan`
1. Apply the Terraform configuration: `terraform apply`
1. Enter `yes` to confirm the planned actions.

## Cleanup

You should now have a new Azure Resource Group (eg: `backend-test-rg`) with a Virtual Network (eg: `test-vnet`).
To cleanup these Azure resources, you can also use Terraform to destroy what it created.

1. If this is a new PowerShell session, you will have to run `scripts\LoadAzureTerraformSecretsToEnvVars.ps1` again
to reload the environment variables needed to Terraform to access Azure.
1. Navigate to the `examples\remote-backend\` folder.
1. Remove the previously created Azure resources: `terraform destroy`
1. Enter `yes` to confirm the planned actions.
