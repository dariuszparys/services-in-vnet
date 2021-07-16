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
  # Key Vault gets a suffix because of the soft delete setting. The same
  # name isn't allowed to be recreated until the soft delete validation time
  # (7 days) has past.
  keyvault_name           = "${local.resource_prefix}-kv-${local.seed_suffix}"
  app_insights_name       = "${local.resource_prefix}-ain"
  vnet_name               = "${local.resource_prefix}-vnet"
  workspace_name          = "${local.resource_prefix}-workspace"
  storage_name            = "${local.storage_prefix}${local.seed_suffix}"
  apps_storage_name       = "${local.storage_prefix}apps${local.seed_suffix}"
}

locals {
  coreapi_name    = lower("${var.project_code}-coreapi-${var.env_code}")
  modelapi_name   = lower("${var.project_code}-modelapi-${var.env_code}")
  frontend_name   = lower("${var.project_code}-frontend-${var.env_code}")
}

locals {
  landing_subnet_name = "LandingSubnet"
  aml_subnet_name     = "AMLSubnet"
  compute_subnet_name = "ComputeSubnet"
  apps_subnet_name    = "AppsSubnet"
}
