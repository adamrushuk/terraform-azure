# Ref using: data.azurerm_subscription.current.subscription_id
data "azurerm_subscription" "current" {}

# Use current logged in Azure creds (Service Principle)
# https://www.terraform.io/docs/providers/azurerm/d/client_config.html
data "azurerm_client_config" "current" {}
