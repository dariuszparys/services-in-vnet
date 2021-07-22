Feature: Azure Container Registry Deployment

  The deployment of ACR must fulfill SKU and Firewall
  configuration (Indenpendent of VNet)

  Scenario: Ensure Premium SKU is installed
    Given I have azurerm_container_registry defined
    Then it must contain SKU
    And its value must be Premium

  Scenario: Ensure Location is in West Europe
    Given I have azurerm_container_registry defined
    Then it must contain location
    And its value must be westeurope

  Scenario: Ensure that admin access is enabled
    Given I have azurerm_container_registry defined
    When it contains admin_enabled
    Then its value must be true

  Scenario: Ensure that firewall configuration is present
    Given I have azurerm_container_registry defined
    Then it must have network_rule_set
    Then it must have default_action
    And its value must not be null
