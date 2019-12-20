# Testing vm-module-3-domain-join

From the root of this repo, run the commands below to apply, test, and destroy as required.

## Assumptions / Prep

Ensure you have renamed `terraform.tfvars.json.example` to `terraform.tfvars.json`, and entered your own values for
the new Azure AD Domain Services instance.

## Apply

```powershell
# Navigate into aadds example folder
cd ./examples/aadds

# Init
terraform init -upgrade

# Plan
# Rename "terraform.tfvars.json.example" to "terraform.tfvars.json", and enter your own values
terraform plan -out=tfplan -var-file="terraform.tfvars.json"

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
Remove-Item -Recurse -Path ".terraform", "tfplan", "terraform.tfstate*"
```

## Troubleshooting

<!-- TODO -->
