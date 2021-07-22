Feature: Azure Storage Deployment

  The deployment of Azure Storage must fulfill network access
  rules

  Scenario: Ensure Location is in West Europe
    Given I have azurerm_storage_account defined
    Then it must contain location
    And its value must be westeurope

  Scenario: Ensure Network Rules are set and Deny access
    Given I have azurerm_storage_account_network_rules defined
    Then it must contain default_action
    And its value must be Deny

  Scenario: Ensure Network Rules are set and bypass Azure Services
    Given I have azurerm_storage_account_network_rules defined
    Then it must contain bypass
    And its value must be AzureServices

  # https://github.com/terraform-compliance/cli/issues/526
  # Scenario: Ensure Network Rules are set and one subnet has access
  #   Given I have azurerm_storage_account_network_rules defined
  #   Then it must contain virtual_network_subnet_ids
  #   And its value must not be null
