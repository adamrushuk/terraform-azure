# Testing Azure AD Domain Services

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

Run the `examples/vm-module-3-domain-join` terraform example to create some VMs and join them to this domain.

## Destroy

```powershell
# Destroy / Cleanup
terraform destroy

# Delete local Terraform files
Remove-Item -Recurse -Path ".terraform", "tfplan", "terraform.tfstate*", "*.rdp" -Force
```

## Troubleshooting

The following error may be shown:

`azurerm_template_deployment.aadds: Error creating deployment: resources.DeploymentsClient#CreateOrUpdate: Failure sending request: StatusCode=400 -- Original Error: Code="InvalidRequestContent" Message="The request content was invalid and could not be deserialized: 'Error converting value \"http://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#\" to type 'Microsoft.WindowsAzure.ResourceStack.Frontdoor.Data.Definitions.DeploymentParameterDefinition'. Path 'properties.parameters.$schema', line 1, position 123456.'.`

Ensure the schema and version lines are removed from the parameters file as per this logged issue:
https://github.com/terraform-providers/terraform-provider-azurerm/issues/1437

The parameter file should start like this:

```json
{
    "apiVersion": {
        "value": "2017-06-01"
    },
    "domainConfigurationType": {
        "value": "FullySynced"
    },
    "domainName": {
        "value": "mydomain.onmicrosoft.com"
    },
    ...[removed]
}
```
