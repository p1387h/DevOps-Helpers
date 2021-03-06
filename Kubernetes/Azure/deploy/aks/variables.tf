variable "name" {
  type        = string
  description = "The name of the AKS and all related resources."
}

variable "aks_version" {
  type        = string
  description = "The Kubernetes cluster version."
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

variable "acr_id" {
  type        = string
  description = "The resource id of the container registry the AKS will be using."
}

variable "current_public_ip" {
  type        = string
  description = "The current public ip of the computer running terraform."
}