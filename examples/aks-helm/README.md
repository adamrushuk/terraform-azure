# Testing Azure Kubernetes Service / Helm

From the root of this repo, run the commands below to apply, test, and destroy as required.

## Assumptions / Prep

Ensure you have logged in to any CLI sessions, usually using a secure credential login script, eg:
`~/.azdev.ps1`

## Apply

```powershell
# Navigate into aadds example folder
cd ./examples/aks-helm

# Init
terraform init -upgrade

# Plan
# Rename "terraform.tfvars.json.example" to "terraform.tfvars.json", and enter your own values
# terraform plan -out=tfplan -var-file="terraform.tfvars.json"
terraform plan -out=tfplan

# Apply
terraform apply tfplan
```

## Test

<!-- TODO -->

## Destroy

```powershell
# Destroy / Cleanup
terraform destroy

# Delete local Terraform files
Remove-Item -Recurse -Path ".terraform", "tfplan", "terraform.tfstate*", "*.rdp" -Force
```
