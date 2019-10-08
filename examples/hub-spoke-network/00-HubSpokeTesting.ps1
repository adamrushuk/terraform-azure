# Hub-spoke network TF build testing
# Navigate to example folder
cd examples\hub-spoke-network

# Run Terraform
terraform init
terraform plan
..\..\scripts\Invoke-Terraform.ps1 -Command "apply"

# Redisplay outputs
terraform output


# TODO - Validate connectivity


# Destroy
..\..\scripts\Invoke-Terraform.ps1 -Command "destroy"
