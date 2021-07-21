variable "resource_group_name" {
  type        = string
  description = "Resource group to use"
  default     = "rg-with-vnet"
}

variable "location" {
  type        = string
  description = "Resource group location"
  default     = "westeurope"
}

variable "project_code" {
  type        = string
  description = "Project identifier"
  default     = "xyz"
}

variable "env_code" {
  type        = string
  description = "Environment identifier"
  default     = "dev"
}

variable "enable_vnet" {
  type        = bool
  description = "Enable VNet configuration"
  default     = false
}