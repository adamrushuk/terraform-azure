# Testing vm-module-3-domain-join

From the root of this repo, run the commands below to apply, test, and destroy as required.

## Assumptions / Prep

1. An `Azure AD Domain Services` instance has been created.
1. The default `aadds-vnet - Address space`  was changed from the default of `10.0.0.0/24` to `10.0.0.0/16`.  
You can use the Azure CLI command below to action this:
    ```powershell
    az network vnet update --resource-group "aadds-rg" --name "aadds-vnet" --address-prefixes "10.0.0.0/16"
    ```
1. You have created a user in Azure AD (eg: `admin` ), and added them to the `AAD DC Administrators`  group.
1. You have reset the above user's password to trigger a password hash sync, as per: https://docs.microsoft.com/en-gb/azure/active-directory-domain-services/tutorial-create-instance#enable-user-accounts-for-azure-ad-ds 
    > For cloud-only user accounts, users must change their passwords before they can use Azure AD DS. This password change process causes the password hashes for Kerberos and NTLM authentication to be generated and stored in Azure AD. You can either expire the passwords for all users in the tenant who need to use Azure AD DS, which forces a password change on next sign-in, or instruct them to manually change their passwords. For this tutorial, let's manually change a user password.

1. You have renamed `terraform.tfvars.json.example` to `terraform.tfvars.json`, and entered your own values from your
new Azure AD Domain Services instance.

## Apply

```powershell
# Navigate into vm-module-3-domain-join folder
cd ./examples/vm-module-3-domain-join

# Init
terraform init -upgrade

# Plan
# Rename "terraform.tfvars.json.example" to "terraform.tfvars.json", and enter your own values
terraform plan -out=tfplan -var-file="terraform.tfvars.json"

# Apply
terraform apply tfplan
```

## Test

Connect to the VM:
```powershell
Get-AzRemoteDesktopFile -ResourceGroupName "terraform-compute-rg" -Name "domjoin0" -LocalPath "$PWD/domjoin0.rdp"
```

## Destroy

```powershell
# Destroy / Cleanup
terraform destroy

# Delete local Terraform files
Remove-Item -Recurse -Path ".terraform", "tfplan", "terraform.tfstate*"
```
