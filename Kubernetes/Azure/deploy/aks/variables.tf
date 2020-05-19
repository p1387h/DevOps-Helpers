variable "resource_group_name" {
  type        = string
  description = "The name of the resource group that all resources are being created in."
}

variable "name" {
  type        = string
  description = "The name of the aks."
}

variable "location" {
  type        = string
  default     = "West Europe"
  description = "The location the cluster is being created in."
}

variable "unique_ending" {
  type        = string
  default     = "123456789"
  description = "String that is used for creating a unique acr name."
}