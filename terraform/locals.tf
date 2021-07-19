resource "random_string" "fourchars" {
  length  = 4
  special = false
  upper   = false
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

locals {
  resource_prefix = lower("${var.project_code}-${var.env_code}")
  storage_prefix  = lower("${var.project_code}${var.env_code}")
  seed_suffix     = random_string.fourchars.result
}

locals {
  app_service_plan_elastic_name   = "${local.resource_prefix}-asp-elastic"
  app_service_plan_linux_name   = "${local.resource_prefix}-asp-linux"
  container_registry_name = replace("${local.resource_prefix}acr${local.seed_suffix}", "-", "")
  keyvault_name           = "${local.resource_prefix}-kv-${local.seed_suffix}"
  app_insights_name       = "${local.resource_prefix}-ain-${local.seed_suffix}"
  vnet_name               = "${local.resource_prefix}-vnet-${local.seed_suffix}"
  workspace_name          = "${local.resource_prefix}-workspace-${local.seed_suffix}"
  storage_name            = "${local.storage_prefix}${local.seed_suffix}"
  apps_storage_name       = "${local.storage_prefix}apps${local.seed_suffix}"
}

locals {
  coreapi_name    = lower("${local.resource_prefix}-coreapi-${local.seed_suffix}")
  modelapi_name   = lower("${local.resource_prefix}-modelapi-${local.seed_suffix}")
  frontend_name   = lower("${local.resource_prefix}-frontend-${local.seed_suffix}")
}

locals {
  landing_subnet_name = "LandingSubnet"
  aml_subnet_name     = "AMLSubnet"
  compute_subnet_name = "ComputeSubnet"
  apps_subnet_name    = "AppsSubnet"
}
