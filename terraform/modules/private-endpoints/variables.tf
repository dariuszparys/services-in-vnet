variable "container_registry_name" {
  type        = string
  description = "Unique name for the container registry"
}

variable "storage_account_name" {
  type        = string
  description = "Unique name for azure storage"
}

variable "function_app_name" {
  type        = string
  description = "Name for function app"
}

variable "app_service_name" {
  type        = string
  description = "Name for app service"
}

variable "env_code" {
  type        = string
  description = "Unique name for the container registry"
  default     = "dev"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group to use"
}

variable "resource_group_location" {
  type        = string
  description = "Location of resource group"
}

variable "private_endpoints_subnet_id" {
  type        = string
  description = "Id of private endpoints subnet"
}

variable "services_subnet_id" {
  type        = string
  description = "Id of services subnet"
}

variable "virtual_network_id" {
  type        = string
  description = "Id of virtual network"
}

variable "resource_prefix" {
  type        = string
  description = "prefix for resource"
}

variable "resource_suffix" {
  type        = string
  description = "suffix for resource"
}