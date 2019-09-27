# Ansible TF build testing
cd ~\Code\terraform-azure\examples\vmss-packer

# Run Terraform
terraform init
terraform plan
~\Code\terraform-azure\scripts\Invoke-Terraform.ps1 -Command "apply"

# Redisplay outputs
terraform output

# Connect to Jumpbox, eg:
ssh azureuser@vmsspackerasr999-ssh.uksouth.cloudapp.azure.com
<# [OPTIONAL] Remove known_hosts if there are SSH connection issues across multiple VM builds, using same FQDN
#>
rm -Path "~/.ssh/known_hosts" -Force -ErrorAction SilentlyContinue

# Create and copy Jumpbox's SSH public key to an internal VMSS instance
# ssh-copy-id remote_username@server_ip_address
ls ~/.ssh
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
ssh-copy-id azureuser@10.0.2.5

# From Jumpbox, can we SSH to VMSS instance eg:
ssh azureuser@10.0.2.5

# Destroy
~\Code\terraform-azure\scripts\Invoke-Terraform.ps1 -Command "destroy"
