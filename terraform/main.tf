terraform {
  required_version = ">= 0.13"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.8.0"
    }
  }
}

provider "azurerm" {
  skip_provider_registration = true
  features {}
}

data "azurerm_client_config" "this" {
}

data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}
