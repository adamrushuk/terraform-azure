# Testing Azure Virtual Machine Scale Sets (VMSS)

From the root of this repo, run the commands below to apply, test, and destroy as required.

## Assumptions / Prep

Ensure you have logged in to any CLI sessions, usually using a secure credential login script, eg:
`~/.azdev.ps1`

## Apply

```powershell
# Navigate into example folder
cd ./examples/vm-scale-set

# Init
terraform init -upgrade

# Plan
terraform plan -out=tfplan

# Apply
terraform apply tfplan

# Show outputs from state file
terraform output
```

## Test

```powershell
# Connect to Jumpbox, eg:
ssh azureuser@vmsspackerasr999-ssh.uksouth.cloudapp.azure.com

# [OPTIONAL] Remove known_hosts if there are SSH connection issues across multiple VM builds, using same FQDN

rm -Path "~/.ssh/known_hosts" -Force -ErrorAction SilentlyContinue

# Create and copy Jumpbox's SSH public key to an internal VMSS instance
# ssh-copy-id remote_username@server_ip_address
ls ~/.ssh
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
ssh-copy-id azureuser@10.0.2.5

# From Jumpbox, can we SSH to VMSS instance eg:
ssh azureuser@10.0.2.5
```

## Destroy

```powershell
# Destroy / Cleanup
terraform destroy

# Delete local Terraform files
Remove-Item -Recurse -Path ".terraform", "tfplan", "terraform.tfstate*", "*.rdp" -Force
```

## Reference

- https://www.terraform.io/docs/providers/azurerm/r/virtual_machine_scale_set.html
