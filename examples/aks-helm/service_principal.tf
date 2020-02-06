# Service Principal for AKS
# source: https://dev.to/cdennig/fully-automated-creation-of-an-aad-integrated-kubernetes-cluster-with-terraform-15cm

# OPTIONAL (alternative)
# Use current logged in Azure creds (Service Principle)
# https://www.terraform.io/docs/providers/azurerm/d/client_config.html
# data "azurerm_client_config" "current" {}


resource "azuread_application" "aks_sp" {
  name                       = local.aks_cluster_name
  homepage                   = "https://${local.aks_cluster_name}"
  identifier_uris            = ["https://${local.aks_cluster_name}"]
  reply_urls                 = ["https://${local.aks_cluster_name}"]
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = false

}

resource "azuread_service_principal" "aks_sp" {
  application_id = azuread_application.aks_sp.application_id
}

resource "random_password" "aks_sp_pwd" {
  length  = 16
  special = true
}

resource "azuread_service_principal_password" "aks_sp_pwd" {
  service_principal_id = azuread_service_principal.aks_sp.id
  value                = random_password.aks_sp_pwd.result
  end_date             = "2024-01-01T01:02:03Z"
}

resource "azurerm_role_assignment" "aks_sp_role_assignment" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.aks_sp.id

  depends_on = [
    azuread_service_principal_password.aks_sp_pwd
  ]
}
