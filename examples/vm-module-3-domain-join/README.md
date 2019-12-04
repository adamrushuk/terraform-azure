# Testing vm-module-3-domain-join

From the root of this repo, run the commands below to apply, test, and destroy as required.

## Assumptions / Prep

1. An `Azure AD Domain Services` instance has been created.
1. The default `aadds-vnet - Address space`  was changed from `10.0.0.0/16` to `10.0.0.0/16`
1. 

## Apply

```powershell
# Navigate into vm-module-3-domain-join folder
cd ./examples/vm-module-3-domain-join

# Init
terraform init -upgrade

# Plan
terraform plan -out=tfplan

# Apply
terraform apply tfplan
```

## Test

Connect to the VM:
```powershell
Get-AzRemoteDesktopFile -ResourceGroupName "terraform-compute" -Name "domjoinvm0" -LocalPath "$PWD/domjoinvm0.rdp"
```

## Destroy

```powershell
# Destroy / Cleanup
terraform destroy

# Delete local Terraform files
Remove-Item -Recurse -Path ".terraform", "tfplan", "terraform.tfstate*"

```
