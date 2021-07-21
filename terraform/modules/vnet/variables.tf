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

variable "vnet_name" {
  type        = string
  description = "Name of the VNet"
}

variable "vnet_address_space" {
  type        = list(string)
  description = "Address space of the VNet"
}

variable "private_endpoints_subnet_name" {
  type        = string
  description = "Name of the private endpoints subnet"
}

variable "private_endpoints_subnet_prefix" {
  type        = string
  description = "CIDR of private endpoints subnet"
}

variable "services_subnet_name" {
  type        = string
  description = "Name of the services subnet"
}

variable "services_subnet_prefix" {
  type        = string
  description = "CIDR of services subnet"
}

variable "gateway_subnet_name" {
  type        = string
  description = "Name of the gateway subnet"
}

variable "gateway_subnet_prefix" {
  type        = string
  description = "CIDR of services subnet"
}
