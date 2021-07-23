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

variable "functionapp_image_name" {
  type        = string
  description = "Name of the container image for the Azure Function App"
  default     = "functionapp"
}

variable "appservice_image_name" {
  type        = string
  description = "Name of the container image for the Azure App Service Web App"
  default     = "appservice"
}

variable "common_image_tag" {
  type        = string
  description = "Common image tag used for both container images"
  default     = "latest"
}