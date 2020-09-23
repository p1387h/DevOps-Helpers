# ----- Storage Account ------------------------------------

output "storage_account_name" {
  value = var.name
}

output "storage_account_key" {
  value = azurerm_storage_account.account.primary_access_key
}