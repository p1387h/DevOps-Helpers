# ----- Setup ----------------------------------------------

# Create the resource group.
resource "azurerm_resource_group" "resource_group" {
  name     = "${local.combined_name}-shared"
  location = var.location
}

locals {
  combined_name = lower("${var.prefix}-${var.name}-${var.suffix}")
  alphanumeric_combined_name = lower("${var.prefix}${var.name}${var.suffix}")
}

# ----- Registry--------------------------------------------

resource "azurerm_container_registry" "acr" {
  name                     = local.alphanumeric_combined_name
  resource_group_name      = azurerm_resource_group.resource_group.name
  location                 = azurerm_resource_group.resource_group.location
  sku                      = "Basic"
}

module "sp_pusher" {
  source = "../service_principal"

  name = "${local.combined_name}-pusher"
}

resource "azurerm_role_assignment" "registry_pusher" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPush"
  principal_id         = module.sp_pusher.sp_object_id
}