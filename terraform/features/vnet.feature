Feature: VNet Compliance

  The deployment of the virtual network must fulfill correct
  address space and subnet creation

  Scenario: Ensure Virtual Network address space is correct
    Given I have azurerm_virtual_network defined
    Then it must contain address_space
    And its value must be 10.0.0.0/16

  Scenario: Ensure VNet Location is in West Europe
    Given I have azurerm_virtual_network defined
    Then it must contain location
    And its value must be westeurope

  Scenario: Ensure multiple subnets
    Given I have azurerm_subnet defined
    When I count them
    Then its value must be 3

  Scenario Outline: Ensure address space is correctly defined in Subnets
    Given I have azurerm_subnet defined
    When its name is <subnet>
    Then it must contain address_prefixes
    And its value must be <addrprefix>

    Examples:
      | subnet                 | addrprefix  |
      | PrivateEndpointsSubnet | 10.0.1.0/24 |
      | ServicesSubnet         | 10.0.2.0/24 |
      | EntrySubnet            | 10.0.3.0/24 |

  # https://github.com/terraform-compliance/cli/issues/526
  # Scenario: Ensure that Services Subnet has delegation
  #   Given I have azurerm_subnet defined
  #   When its name is services
  #   Then it must contain delegation
  #   Then it must contain service_delegation
  #   Then it must contain name
  #   And its values must be "services_subnet_delegation"
