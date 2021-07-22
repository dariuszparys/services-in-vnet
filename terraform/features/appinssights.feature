Feature: Application Insights Deployment

  The deployment of Application Insights must fulfill the
  minimum requirements of being used for web applications

  Scenario: Ensure Location is in West Europe
    Given I have azurerm_application_insights defined
    Then it must contain location
    And its value must be westeurope

  Scenario: Ensure that type is web
    Given I have azurerm_application_insights defined
    Then it must contain application_type
    And its value must be web