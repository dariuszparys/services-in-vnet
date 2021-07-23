variable "storage_account_name" {
  type        = string
  description = "Name of the storage account"
}

variable "storage_account_access_key" {
  type        = string
  description = "Primary key of the storage account"
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

variable "app_service_plan_name" {
  type        = string
  description = "Unique name for the app service plan"
}

variable "container_registry_url" {
  type        = string
  description = "Url of azure container registry"
}

variable "container_registry_username" {
  type        = string
  description = "User of azure container registry"
}

variable "container_registry_password" {
  type        = string
  description = "Password of azure container registry"
}

variable "function_app_name" {
  type        = string
  description = "Unique name for the function app"
}

variable "app_service_name" {
  type        = string
  description = "Unique name for the app service"
}

variable "app_insights_key" {
  type        = string
  description = "Instrumentation key for application insights"
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