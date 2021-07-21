variable "app_insights_name" {
  type        = string
  description = "Unique name for the application insights"
}

variable "env_code" {
  type        = string
  description = "Environment code"
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