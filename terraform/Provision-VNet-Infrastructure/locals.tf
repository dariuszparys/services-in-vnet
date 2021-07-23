resource "random_string" "fourchars" {
  length  = 4
  special = false
  upper   = false
}

locals {
  resource_prefix = lower("${var.project_code}-${var.env_code}")
  storage_prefix  = lower("${var.project_code}${var.env_code}")
  seed_suffix     = random_string.fourchars.result
}

locals {
  app_service_plan_name         = "${local.resource_prefix}-asp-${local.seed_suffix}"
  container_registry_name       = replace("${local.resource_prefix}acr${local.seed_suffix}", "-", "")
  app_insights_name             = "${local.resource_prefix}-ain-${local.seed_suffix}"
  storage_name                  = "${local.storage_prefix}${local.seed_suffix}"
  function_app_name             = lower("${local.resource_prefix}-functionapp-${local.seed_suffix}")
  app_service_name              = lower("${local.resource_prefix}-appservice-${local.seed_suffix}")
  vnet_name                     = "${local.resource_prefix}-vnet-${local.seed_suffix}"
}
