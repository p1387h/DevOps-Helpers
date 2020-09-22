# ----- Registry -------------------------------------------

output "acr_id" {
  value = azurerm_container_registry.acr.id
}

output "acr_pusher_app_id" {
  value = module.sp_pusher.app_application_id
}

output "acr_pusher_app_secret" {
  value = module.sp_pusher.app_password
}