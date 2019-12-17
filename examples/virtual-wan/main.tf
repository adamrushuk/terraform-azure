# https://www.terraform.io/docs/providers/azurerm/r/point_to_site_vpn_gateway.html
resource "azurerm_resource_group" "p2svpn" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_wan" "p2svpn" {
  name                = "p2svpn-vwan"
  resource_group_name = azurerm_resource_group.p2svpn.name
  location            = azurerm_resource_group.p2svpn.location
}

resource "azurerm_virtual_hub" "p2svpn" {
  name                = "p2svpn-virtualhub"
  resource_group_name = azurerm_resource_group.p2svpn.name
  location            = azurerm_resource_group.p2svpn.location
  virtual_wan_id      = azurerm_virtual_wan.p2svpn.id
  address_prefix      = "10.100.100.0/24"
}

resource "azurerm_vpn_server_configuration" "p2svpn" {
  name                     = "p2svpn-config"
  resource_group_name      = azurerm_resource_group.p2svpn.name
  location                 = azurerm_resource_group.p2svpn.location
  # Possible values are AAD (Azure Active Directory), Certificate and Radius
  vpn_authentication_types = ["Certificate"]

  # radius_server {
  #   address = ""
  #   secret = ""
  #   # OPTIONAL
  #   # client_root_certificate = ""
  #   # server_root_certificate = ""
  # }

# # https://github.com/terraform-providers/terraform-provider-azurerm/blob/master/azurerm/resource_arm_vpn_server_configuration_test.go#L265
#   azure_active_directory_authentication {
#     audience = "https://www.example.com/"
#     issuer   = "https://login.windows.net/"
#     tenant   = "example.onmicrosoft.com"
#   }

  client_root_certificate {
    name             = "DigiCert-Federated-ID-Root-CA"
    public_cert_data = <<EOF
MIIDuzCCAqOgAwIBAgIQCHTZWCM+IlfFIRXIvyKSrjANBgkqhkiG9w0BAQsFADBn
MQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3
d3cuZGlnaWNlcnQuY29tMSYwJAYDVQQDEx1EaWdpQ2VydCBGZWRlcmF0ZWQgSUQg
Um9vdCBDQTAeFw0xMzAxMTUxMjAwMDBaFw0zMzAxMTUxMjAwMDBaMGcxCzAJBgNV
BAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdp
Y2VydC5jb20xJjAkBgNVBAMTHURpZ2lDZXJ0IEZlZGVyYXRlZCBJRCBSb290IENB
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvAEB4pcCqnNNOWE6Ur5j
QPUH+1y1F9KdHTRSza6k5iDlXq1kGS1qAkuKtw9JsiNRrjltmFnzMZRBbX8Tlfl8
zAhBmb6dDduDGED01kBsTkgywYPxXVTKec0WxYEEF0oMn4wSYNl0lt2eJAKHXjNf
GTwiibdP8CUR2ghSM2sUTI8Nt1Omfc4SMHhGhYD64uJMbX98THQ/4LMGuYegou+d
GTiahfHtjn7AboSEknwAMJHCh5RlYZZ6B1O4QbKJ+34Q0eKgnI3X6Vc9u0zf6DH8
Dk+4zQDYRRTqTnVO3VT8jzqDlCRuNtq6YvryOWN74/dq8LQhUnXHvFyrsdMaE1X2
DwIDAQABo2MwYTAPBgNVHRMBAf8EBTADAQH/MA4GA1UdDwEB/wQEAwIBhjAdBgNV
HQ4EFgQUGRdkFnbGt1EWjKwbUne+5OaZvRYwHwYDVR0jBBgwFoAUGRdkFnbGt1EW
jKwbUne+5OaZvRYwDQYJKoZIhvcNAQELBQADggEBAHcqsHkrjpESqfuVTRiptJfP
9JbdtWqRTmOf6uJi2c8YVqI6XlKXsD8C1dUUaaHKLUJzvKiazibVuBwMIT84AyqR
QELn3e0BtgEymEygMU569b01ZPxoFSnNXc7qDZBDef8WfqAV/sxkTi8L9BkmFYfL
uGLOhRJOFprPdoDIUBB+tmCl3oDcBy3vnUeOEioz8zAkprcb3GHwHAK+vHmmfgcn
WsfMLH4JCLa/tRYL+Rw/N3ybCkDp00s0WUZ+AoDywSl0Q/ZEnNY0MsFiw6LyIdbq
M/s/1JRtO3bDSzD9TazRVzn2oBqzSa8VgIo5C1nOnoAKJTlsClJKvIhnRlaLQqk=
EOF
  }
}

resource "azurerm_point_to_site_vpn_gateway" "p2svpn" {
  name                        = "p2svpn-vpn-gateway"
  location                    = azurerm_resource_group.p2svpn.location
  resource_group_name         = azurerm_resource_group.p2svpn.name
  virtual_hub_id              = azurerm_virtual_hub.p2svpn.id
  vpn_server_configuration_id = azurerm_vpn_server_configuration.p2svpn.id
  scale_unit                  = 1
  connection_configuration {
    name = "conn_conf"
    vpn_client_address_pool {
      address_prefixes = ["172.16.200.0/24"]
    }
  }
}
