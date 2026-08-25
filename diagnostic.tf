resource "azurerm_storage_account" "kv_logs" {
  name                     = "st${replace(var.prefix, "-", "")}kvlogs"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  public_network_access_enabled = true
}
# Key Vault Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "kv_diagnostics" {
  name               = "kv-diagnostics"
  target_resource_id = azurerm_key_vault.kv.id
  storage_account_id = azurerm_storage_account.kv_logs.id

  enabled_log {
    category = "AuditEvent"
  }
  enabled_log {
    category = "AzurePolicyEvaluationDetails"
  }
}
