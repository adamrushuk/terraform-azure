# Linux VM Example

This example provisions a Linux VM with boot diagnositcs enabled, and runs both script files and inline code.

## Connect

To connect to the VM in Azure, run the command shown after running `terraform output ssh_connection`,
eg: `ssh azureuser@myvmdb0178b07315a538.eastus.cloudapp.azure.com`

## Activate Virtual Environment

To activate the virtual environment, run: `source ~/python-env/ansible2.8.4/bin/activate`

## Save Current Python Module Versions

Run: `pip freeze > requirements.txt`
