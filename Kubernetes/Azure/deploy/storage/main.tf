# ----- Storage Account ------------------------------------

resource "azurerm_storage_account" "account" {
  name                     = var.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "ZRS"

  network_rules {
    default_action             = length(var.subnet_ids) > 0 ? "Deny" : "Allow"
    ip_rules                   = [var.creator_ip]
    virtual_network_subnet_ids = var.subnet_ids
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to the ip rules since they should be removed afterwards.
      network_rules[0].ip_rules
    ]
  }
}

resource "azurerm_storage_share" "shares" {
  for_each             = toset(var.share_names)
  name                 = each.key
  storage_account_name = azurerm_storage_account.account.name
  quota                = 50
}