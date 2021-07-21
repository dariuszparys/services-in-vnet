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

variable "gateway_subnet_id" {
  type        = string
  description = "Id of gateway subnet"
}

variable "enable_vnet" {
  type        = string
  description = "Activate vnet"
}

variable "resource_prefix" {
  type        = string
  description = "prefix for resource"
}

variable "resource_suffix" {
  type        = string
  description = "suffix for resource"
}

variable "app_service_fqdns" {
  type        = string
  description = "Fully qualified domain name for app service"
}