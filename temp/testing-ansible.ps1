# Ansible TF build testing
cd ~\Code\terraform-azure\examples\linux-vm-remoteexec-ansible

# Run Terraform
terraform init
terraform plan
~\Code\terraform-azure\scripts\Invoke-Terraform.ps1 -Command "apply"

# Taint certain resources to recreate just those
terraform taint null_resource.init
terraform taint azurerm_virtual_machine.myterraformvm

<# [OPTIONAL] Remove known_hosts if there are SSH connection issues across multiple VM builds, using same FQDN
rm -Path "~/.ssh/known_hosts" -Force
#>
# Open SSH session
# eg: ssh azureuser@<VMNAME>.eastus.cloudapp.azure.com
Invoke-Expression -Command $(terraform output ssh_connection)

# Active Python virtual environment
# * You cannot F8 this line within SSH session in VSCode
source ~/python-env/ansible2.8.4/bin/activate

# Test Ansible command
ansible localhost -m setup

# Leave SSH session
exit

# Destroy
~\Code\terraform-azure\scripts\Invoke-Terraform.ps1 -Command "destroy"

<# WARNING: Deletes EVERYTHING not tagged "keep"
~\Code\terraform-azure\scripts\Delete-ResourceGroupNotTaggedKeep.ps1
#>
