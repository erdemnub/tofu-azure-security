# This file contains the configuration for the database resources in Azure.

resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# The database server resource

resource "azurerm_key_vault_secret" "db_admin_pass" {
  name         = "db-admin-password"
  value        = random_password.db_password.result
  key_vault_id = azurerm_key_vault.kv.id
}

# Delegated subnet for the database server

resource "azurerm_subnet" "db_subnet" {
  name                 = "snet-db-001"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]

  delegation {
    name = "fs-delegation"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}

# PostgreSQL Private DNS zone for the database server

resource "azurerm_private_dns_zone" "postgres_dns" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}


resource "azurerm_private_dns_zone_virtual_network_link" "postgres_dns_link" {
  name                 = "postgres-vnet-link"
  private_dns_zone_id  = azurerm_private_dns_zone.postgres_dns.id
  virtual_network_id   = azurerm_virtual_network.vnet.id
  registration_enabled = false
}

# PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "db_flex_server" {
  name                          = "psql-${var.prefix}-001"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  version                       = "15"
  delegated_subnet_id           = azurerm_subnet.db_subnet.id
  private_dns_zone_id           = azurerm_private_dns_zone.postgres_dns.id
  administrator_login           = "psqladmin"
  administrator_password        = random_password.db_password.result
  zone                          = "1"
  public_network_access_enabled = false

  storage_mb = 32768
  sku_name   = "B_Standard_B1ms"

  depends_on = [azurerm_private_dns_zone_virtual_network_link.postgres_dns_link]
}