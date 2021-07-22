Feature: Application Gateway Deployment

  The deployment of Application Gateway must fulfill the requirements
  to setup a gateway with frontend and backend configuration

  Scenario: Ensure Location is in West Europe
    Given I have azurerm_application_gateway defined
    Then it must contain location
    And its value must be westeurope

  Scenario: Ensure Standard_V2 SKU is installed
    Given I have azurerm_application_gateway defined
    When it has SKU
    Then it must have SKU
    Then it must have name
    And its value must be Standard_V2

  # https://github.com/terraform-compliance/cli/issues/526
  # Scenario: Ensure Gateway Ip is configured
  #   Given I have azurerm_application_gateway defined
  #   Then it must have gateway_ip_configuration
  #   Then it must have subnet_id
  #   And its value must not be null

  # https://github.com/terraform-compliance/cli/issues/526
  # Scenario: Ensure Frontend Ip is configured
  #   Given I have azurerm_application_gateway defined
  #   Then it must have frontend_ip_configuration
  #   Then it must have public_ip_address_id
  #   And its value must not be null

  # https://github.com/terraform-compliance/cli/issues/526
  # Scenario: Ensure Backend Address Pool is configured
  #   Given I have azurerm_application_gateway defined
  #   Then it must have backend_address_pool
  #   Then it must have fqdns
  #   And its value must not be null

  Scenario Outline: Ensure Backend Http Settings are configured
    Given I have azurerm_application_gateway defined
    When it has backend_http_settings
    Then it must have backend_http_settings
    Then it must contain <key>
    And its value must be <value>

    Examples:
      | key                                 | value |
      | request_timeout                     | 240   |
      | pick_host_name_from_backend_address | true  |

  Scenario: Ensure Http Listener is configured
    Given I have azurerm_application_gateway defined
    Then it must have http_listener
    Then it must have protocol
    And its value must be Http
