# Create a Remote Backend
terraform {
  backend "azurerm" {
    # storage_account_name needs to be changed manually as variables are not supported.
    # Should be a format like "<random chars>terraform", eg: "am1ojbxsfterraform"
    storage_account_name = "<REPLACE-WITH-YOUR-STORAGE-ACCOUNT-NAME>"
    container_name       = "terraform-state"
    key                  = "terraform.tfstate"

    # access_key provided via ARM_ACCESS_KEY env var
  }
}

# Configure the Azure Provider
provider "azurerm" {
  # Pin version as per best practice
  version = "=1.22.0"
}

# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"

  tags {
    environment = "test"
  }
}

# Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.virtual_network_name}"
  address_space       = "${var.address_space}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  tags {
    environment = "test"
  }
}
