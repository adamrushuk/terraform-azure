# Linux VM Ansible Example

This example provisions a Linux VM with boot diagnositcs enabled. Multiple scripts are uploaded and executed, then
inline code is run.

## Connect

To connect to the VM in Azure, run the command shown after running `terraform output ssh_connection`,
eg: `ssh azureuser@myvm<random>.eastus.cloudapp.azure.com`

## Activate Virtual Environment

Once connected, activate the virtual environment by running: `source ~/python-env/ansible2.8.4/bin/activate`

## Save Current Python Module Versions

Run: `pip freeze > requirements.txt`
