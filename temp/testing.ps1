# Ansible TF build testing
cd ~\Code\terraform-azure\examples\linux-vm-remoteexec-ansible

terraform init
terraform plan

~\Code\terraform-azure\scripts\Start-Terraform.ps1

terraform taint null_resource.init
terraform taint azurerm_virtual_machine.myterraformvm

rm -Path "~/.ssh/known_hosts" -Force
ssh azureuser@<VMNAME>.eastus.cloudapp.azure.com

source ~/python-env/ansible2.8.4/bin/activate

terraform destroy -auto-approve

<# WARNING: Deletes EVERYTHING not tagged "keep"
~\Code\terraform-azure\scripts\Delete-ResourceGroupNotTaggedKeep.ps1
#>
