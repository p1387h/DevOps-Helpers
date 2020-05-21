variable "name" {
  type        = string
  description = "The name of the AKS and all related resources."
}

variable "location" {
  type        = string
  description = "The location the cluster is being created in."
}

variable "prefix" {
  type        = string
  description = "String that is being used as a prefix for all resources that are being created."
}

variable "suffix" {
  type        = string
  description = "String that is being used as a suffix for all resources that are being created."
}