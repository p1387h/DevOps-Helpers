variable "resource_group_name" {
  type        = string
  description = "The name of the resource group the storage account is being created in."
}

variable "name" {
  type        = string
  description = "The full name of the storage account including pre-/suffixes."
}

variable "location" {
  type        = string
  description = "The location the storage account is being created in."
}

variable "subnet_ids" {
  type        = list(string)
  description = "The resource ids of the subnets that are allowed to access the storage account."
}

variable "creator_ip" {
  type        = string
  description = "The current public ip of the terraform creator. Is needed for creating the storage account ip rules and should be removed afterwards."
}

variable "share_names" {
  type        = list(string)
  description = "The names of the shares that are being created inside the storage account."
}