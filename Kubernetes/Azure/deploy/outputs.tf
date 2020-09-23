# ----- Registry -------------------------------------------

output "acr_pusher_app_id" {
  value = module.shared.acr_pusher_app_id
}

output "acr_pusher_app_secret" {
  value = module.shared.acr_pusher_app_secret
}

# ----- Networking -----------------------------------------

output "public_ip" {
  value = module.aks.public_ip
}

output "public_fqdn" {
  value = module.aks.public_fqdn
}

# ----- AKS Resources --------------------------------------

output "resource_group_resources" {
  value = module.aks.resource_group_resources
}

output "resource_group_nodes" {
  value = module.aks.resource_group_nodes
}

output "aks_resource_name" {
  value = module.aks.aks_resource_name
}

output "aks_name" {
  value = module.aks.name
}

# ----- Service Principal ----------------------------------

output "admin_app_id" {
  value = module.aks.admin_app_id
}

output "admin_app_secret" {
  value = module.aks.admin_app_secret
}

# ----- Storage Account ------------------------------------

output "storage_account_name" {
  value = module.aks.storage_name
}

output "storage_account_key" {
  value = module.aks.storage_key
}