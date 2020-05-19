resource "azuread_application" "application" {
   name            = var.name
   identifier_uris = ["https://${var.name}"]
}

resource "azuread_service_principal" "service_principal" {
  application_id = "${azuread_application.application.application_id}"
}

resource "azuread_service_principal_password" "password" {
  service_principal_id = "${azuread_service_principal.service_principal.id}"
  value                = random_password.password.result
  end_date             = "2999-01-01T00:00:00Z"
}

resource "random_password" "password" {
  length      = 16
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  special     = false
}