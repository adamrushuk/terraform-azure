# Assign variables
environment         = "staging"
location            = "uksouth"
resource_group_name = "rsha-rg-vmss"

admin_username = "sysadmin"
admin_password = "Pa55word!Pa55word!"

address_space = ["10.0.0.0/16"]

vm_image_publisher = "RedHat"
vm_image_offer     = "RHEL"
vm_image_sku       = "7-RAW-CI"
vm_image_version   = "latest"

scaleset_vm_size  = "Standard_DS2_v2"
scaleset_capacity = 2
