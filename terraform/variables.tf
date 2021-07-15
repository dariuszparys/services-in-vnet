variable "project_code" {
  type        = string
  description = "Project code such as mlops. This value is used as a prefix to name the resources."
}

variable "env_code" {
  type        = string
  description = "Environment code such as dev/prod. This value is used as a prefix to name the resources."
  default     = "dev"
}

variable "location" {
  type        = string
  description = "Location where the resources should be created"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to deploy the resources to"
}

variable "vnet_address_space" {
  type        = list(string)
  description = "The address space that is used by the virtual network."
  default     = ["10.0.0.0/16"]
}

variable "aml_subnet_prefix" {
  description = "The address prefix to use for the aml subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "compute_subnet_prefix" {
  description = "The address prefix to use for the compute subnet."
  type        = string
  default     = "10.0.2.0/24"
}

variable "landing_subnet_prefix" {
  description = "The address prefix to use for the landing subnet."
  type        = string
  default     = "10.0.3.0/24"
}

variable "apps_subnet_prefix" {
  description = "The address prefix to use for the apps subnet."
  type        = string
  default     = "10.0.4.0/24"
}

variable "deploy_to_vnet" {
  description = "Enable / disable private endpoints"
  type        = bool
  default     = true
}

variable "vmss_admin_user" {
  description = "Admin user account to log into the vmss instance"
  type        = string
}

variable "source_image_id" {
  description = "Image to be used for the AzDO agent pool scale set"
  type        = string
}