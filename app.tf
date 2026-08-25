# private subnet for app service

resource "azurerm_subnet" "app_subnet" {
  name                 = "snet-app-001"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.3.0/24"]

  delegation {
    name = "app-service-delegation"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"
      ]
    }
  }
}

# Linux app service plan (B1)
resource "azurerm_service_plan" "asp" {
  name                = "asp-${var.prefix}-001"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "B1"
}

# FASTAPI app service
resource "azurerm_linux_web_app" "fastapi_app" {
  name                = "app-fastapi-${var.prefix}-001"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.asp.id
  https_only          = true

  virtual_network_subnet_id                      = azurerm_subnet.app_subnet.id
  public_network_access_enabled                  = false
  ftp_publish_basic_authentication_enabled       = false
  webdeploy_publish_basic_authentication_enabled = false


  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app_identity.id]
  }

  site_config {
    always_on = false
    application_stack {
      python_version = "3.11"
    }
  }

  app_settings = {
    "AZURE_CLIENT_ID"                = azurerm_user_assigned_identity.app_identity.client_id
    "KEY_VAULT_NAME"                 = azurerm_key_vault.kv.name
    "DB_HOST"                        = azurerm_postgresql_flexible_server.db_flex_server.fqdn
    "DB_NAME"                        = "postgres"
    "DB_USER"                        = azurerm_postgresql_flexible_server.db_flex_server.administrator_login
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
  }

  depends_on = [
    azurerm_role_assignment.kv_secrets_user,
    azurerm_postgresql_flexible_server.db_flex_server
  ]
}