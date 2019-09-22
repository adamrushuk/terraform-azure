# Ansible TF build testing
cd ~\Code\terraform-azure\examples\vmss-packer

# Run Terraform
terraform init
terraform plan
~\Code\terraform-azure\scripts\Invoke-Terraform.ps1 -Command "apply"

# Redisplay outputs
terraform output

# Destroy
~\Code\terraform-azure\scripts\Invoke-Terraform.ps1 -Command "destroy"
