# ----- Application ----------------------------------------

output "app_object_id" {
  value       = azuread_application.application.id
  description = "The object id of the created application."
}

output "app_application_id" {
  value       = azuread_application.application.application_id
  description = "The application id of the created application."
}

output "app_password" {
  value       = random_password.password.result
  description = "The password of the created service application."
}

# ----- Service Principal ----------------------------------

output "sp_object_id" {
  value       = azuread_service_principal.service_principal.object_id
  description = "The object id of the created service principal."
}