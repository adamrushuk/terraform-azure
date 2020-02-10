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

## Reference

- https://hub.docker.com/r/sonatype/nexus3/#persistent-data
- https://medium.com/stakater/k8s-deployments-vs-statefulsets-vs-daemonsets-60582f0c62d4
