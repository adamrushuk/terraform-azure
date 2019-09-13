# Assign variables
environment         = "staging"
location            = "eastus"
resource_group_name = "asrsstest123rg"

admin_username = "azureuser"
admin_password = "Pa55word!Pa55word!"

address_space = ["10.0.0.0/16"]

vm_image_publisher = "OpenLogic"
vm_image_offer     = "CentOS"
vm_image_sku       = "7.6"
vm_image_version   = "latest"

scaleset_vm_size  = "Standard_B1s"
scaleset_capacity = 2
