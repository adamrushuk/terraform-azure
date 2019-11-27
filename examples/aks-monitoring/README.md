# TODO

## Environment variables

Environment variables can be created for sensitive values like Service Principle values:

```bash
# Bash
export TF_VAR_kubernetes_client_id="<MyAzureSpClientId>"
export TF_VAR_kubernetes_client_secret="<MyAzureSpClientSecret>"
```

```powershell
# PowerShell
$env:TF_VAR_kubernetes_client_id = "<MyAzureSpClientId>"
$env:TF_VAR_kubernetes_client_secret = "<MyAzureSpClientSecret>"

# [Optional] Reuse current ARM env vars
$env:TF_VAR_kubernetes_client_id = $env:ARM_CLIENT_ID
$env:TF_VAR_kubernetes_client_secret = $env:ARM_CLIENT_SECRET
```

```powershell
# AKS Monitoring Terraform build testing
# Run Terraform
terraform init
terraform plan
..\..\scripts\Invoke-Terraform.ps1 -Command "apply"
```
