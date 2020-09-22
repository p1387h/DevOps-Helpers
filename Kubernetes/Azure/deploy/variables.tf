# ----- Shared resources -----------------------------------

variable "shared_name" {
  type        = string
  description = "The name of the resource group that all shared resources are being created in."
}

# ----- AKS ------------------------------------------------

variable "aks_name" {
  type        = string
  description = "The name of the resource group that all aks resources are being created in."
}