# Testing vm-module-3-domain-join

From the root of this repo, run the commands below to apply, test, and destroy as required.

## Assumptions / Prep

1. An `Azure AD Domain Services` instance has been created.
1. The default `aadds-vnet - Address space`  was changed from the default of `10.0.0.0/24` to `10.0.0.0/16`.
You can use the Azure CLI command below to action this:
    ```powershell
    az network vnet update --resource-group "aadds-rg" --name "aadds-vnet" --address-prefixes "10.0.0.0/16"
    ```
1. Your VNET DNS servers are set to Custom, using the AADDS DC IP addresses (eg: `10.0.0.4`, `10.0.0.5`).
You can use the Azure CLI command below to action this:
    ```powershell
    az network vnet update --resource-group "aadds-rg" --name "aadds-vnet" --dns-servers "10.0.0.4" "10.0.0.5"

    # Warning: if you have running VMs before updating the DNS IP addresses
    # you will need to reboot them for the changes to take effect
    az vm restart --ids $(az vm list -g "terraform-compute-rg" --query "[].id" -o tsv)
    ```
1. You have created a user in Azure AD (eg: `admin`), and added them to the `AAD DC Administrators`  group.
1. You have [logged in here](https://account.activedirectory.windowsazure.com/) and reset the above user's password
   to trigger a password hash sync, as per:
   https://docs.microsoft.com/en-gb/azure/active-directory-domain-services/tutorial-create-instance#enable-user-accounts-for-azure-ad-ds
    > For cloud-only user accounts, users must change their passwords before they can use Azure AD DS.
    This password change process causes the password hashes for Kerberos and NTLM authentication to be generated
    and stored in Azure AD. You can either expire the passwords for all users in the tenant who need to use
    Azure AD DS, which forces a password change on next sign-in, or instruct them to manually change their
    passwords. For this tutorial, let's manually change a user password.
1. You have renamed `terraform.tfvars.json.example` to `terraform.tfvars.json`, and entered your own values from your
new Azure AD Domain Services instance.

## Apply

```powershell
# Navigate into vm-module-3-domain-join folder
cd ./examples/vm-module-3-domain-join

# Init
terraform init -upgrade

# Plan
# Rename "terraform.tfvars.json.example" to "terraform.tfvars.json", and enter your own values
terraform plan -out=tfplan -var-file="terraform.tfvars.json"

# Apply
terraform apply tfplan
```

## Test

Connect to the VM by downloading the RDP connection file:
```powershell
# Connect PowerShell to Azure
Connect-AzAccount

# Download RDP connection file
Get-AzRemoteDesktopFile -ResourceGroupName "<MyResourceGroup>" -Name "<MyVmName>" -LocalPath "$PWD/<MyVmName>.rdp"
# eg:
Get-AzRemoteDesktopFile -ResourceGroupName "terraform-compute-rg" -Name "domjoin0" -LocalPath "$PWD/domjoin0.rdp"
```

### Connect using an Azure AD user account

Initially you will only be able to connect using the specified local admin name (`sysadmin`).

Even if your Azure AD user is a member of the `AAD DC Administrators` Azure AD group, you may not be able to connect
using RDP.

Adding the Azure AD `AAD DC Administrators` group into the local Administrators group within the VM will allow RDP
connections.

### Installing Remote Server Administration Tools (RSAT) to manage AADDS

Once logged into your domain-joined VM as an Azure AD user, you can install RSAT to enable standard AD tools like
`AD User and Computers`.

```powershell
# Install RSAT
Install-WindowsFeature -IncludeAllSubFeature "RSAT"
```

## Destroy

```powershell
# Destroy / Cleanup
terraform destroy

# Delete local Terraform files
Remove-Item -Recurse -Path ".terraform", "tfplan", "terraform.tfstate*"
```

## Troubleshooting

Domain join extension logs can be found on target VM here: `C:\WindowsAzure\Logs\Plugins\Microsoft.Compute.JsonADDomainExtension\1.3.2`

You may see the `User Specified without NetSetupAcctCreate` error, along with one of the following codes:

- Error code 1355
- Error code 1907
- Error code 1326

You can get the extension details, and remove the extension (if required) by using these PowerShell commands:

```powershell
# Get and remove extension
Get-AzVMExtension -ResourceGroupName "<resourceGroupName>" -VMName "<vmName>" -Name "myExtensionName"
Remove-AzVMExtension -ResourceGroupName "myResourceGroup" -VMName "myVM" -Name "myExtensionName" -Force

# Example
Get-AzVMExtension -ResourceGroupName "terraform-compute-rg" -VMName "domjoin0" -Name "domjoinext"
"domjoin0", "domjoin1" | Foreach-Object { Remove-AzVMExtension -ResourceGroupName "terraform-compute-rg" -VMName $_ -Name "domjoinext" -Force -Verbose }
```

### Things to Check

- Have you changed your domain user password to ensure password sync occurs?
- Have you confirmed the OU you're specifying already exists?
- Does the user account you're specifying belong to the `AAD DC Administrators` group?
- Have you updated your VM's VNET DNS settings with the IPs of the new Domain Controllers (eg. 10.0.0.4, 10.0.0.5),
  rebooted the VM and confirmed it's using the new IPs of AADDS DCs?

**Reference**: https://docs.microsoft.com/en-gb/azure/active-directory-domain-services/join-windows-vm#troubleshoot-domain-join-issues

### Regenerate the VM RDP files

To regenarate the VM RDP files, run the following commands

```powershell
# Mark resources as tainted
terraform taint null_resource.rdp[0]
terraform taint null_resource.rdp[1]

# Plan and apply
terraform plan -out=tfplan -var-file="terraform.tfvars.json"
terraform apply tfplan
```
