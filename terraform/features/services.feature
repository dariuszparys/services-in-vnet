Feature: Services Deployment

  The deployment of services must fulfill correct
  Azure Service Plan, Function App and App Service configuration

  Scenario: Ensure Location is in West Europe
    Given I have azurerm_app_service_plan defined
    Then it must contain location
    And its value must be westeurope

  Scenario: Ensure Premium tier SKU is selected
    Given I have azurerm_app_service_plan defined
    When it has SKU
    And it contains Tier
    Then its value must be PremiumV2

  Scenario: Ensure P1v2 size SKU is selected
    Given I have azurerm_app_service_plan defined
    When it has SKU
    And it contains Size
    Then its value must be P1v2

  Scenario: Ensure function app is deployed with private endpoint
    Given I have azurerm_private_endpoint defined
    When its name is function_app_pe
    Then it must contain private_service_connection

  # Due to this issue I need to comment out
  # https://github.com/terraform-compliance/cli/issues/526
  # Scenario: Ensure function app is deployed with vnet integration
  #   Given I have azurerm_app_service_virtual_network_swift_connection defined
  #   Then it must have subnet_id
  #   And its value must not be null

  Scenario: Ensure function app is using Linux
    Given I have azurerm_function_app defined
    Then it must have os_type
    And its value must be linux

  Scenario: Ensure function app has pre-warmed instances
    Given I have azurerm_function_app defined
    When it has site_config
    Then it must have site_config
    Then it must have pre_warmed_instance_count
    And its value must be 1

  # https://github.com/terraform-compliance/cli/issues/526
  # Scenario: Ensure function app has correct Azure DNS Server when running in VNet
  #   Given I have app_settings defined
  #   When it has app_settings
  #   Then it must have app_settings
  #   When it has WEBSITE_DNS_SERVER
  #   Then it must have WEBSITE_DNS_SERVER
  #   And its value must be "168.63.129.16"

  # https://github.com/terraform-compliance/cli/issues/526
  # Scenario: Ensure function app usage of app insights
  #   Given I have azurerm_function_app defined
  #   When it has app_settings
  #   Then it must have app_settings
  #   And any of its values must match the "(azurerm_application_insights.shared)" regex

  # https://github.com/terraform-compliance/cli/issues/526
  # Scenario: Ensure app service usage of app insights
  #   Given I have azurerm_app_service defined
  #   When it has app_settings
  #   Then it must have app_settings
  #   And any of its values must match the "(azurerm_application_insights.shared)" regex


