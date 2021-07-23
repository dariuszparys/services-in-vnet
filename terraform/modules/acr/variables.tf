variable "container_registry_name" {
  type        = string
  description = "Unique name for the container registry"
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

variable "enable_vnet" {
  type        = string
  description = "Activate vnet"
}

variable "functionapp_image_name" {
  type        = string
  description = "Activate vnet"
}

variable "appservice_image_name" {
  type        = string
  description = "Activate vnet"
}

variable "common_image_tag" {
  type        = string
  description = "Activate vnet"
}