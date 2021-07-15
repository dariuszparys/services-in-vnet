# Terraform Deployment

## Deploy Environment

tbd / change to deploy from console

## Input Values

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| [aml\_subnet\_prefix](#input\_aml\_subnet\_prefix) | The address prefix to use for the aml subnet. | `string` | `"10.0.1.0/24"` | no |
| [compute\_subnet\_prefix](#input\_compute\_subnet\_prefix) | The address prefix to use for the compute subnet. | `string` | `"10.0.2.0/24"` | no |
| [deploy\_to\_vnet](#input\_deploy\_to\_vnet) | Enable / disable private endpoints | `bool` | `true` | no |
| [enable\_private\_endpoint](#input\_enable\_private\_endpoint) | Enable / disable private endpoints | `bool` | `true` | no |
| [env\_code](#input\_env\_code) | Environment code such as dev/prod. This value is used as a prefix to name the resources. | `string` | `"dev"` | no |
| [google\_staticmap\_key](#input\_google\_staticmap\_key) | Key for google static maps access | `string` | n/a | yes |
| [location](#input\_location) | Location where the resources should be created | `string` | n/a | yes |
| [project\_code](#input\_project\_code) | Project code such as mlops. This value is used as a prefix to name the resources. | `string` | n/a | yes |
| [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group to deploy the resources to | `string` | n/a | yes |
| [source\_image\_id](#input\_source\_image\_id) | Image to be used for the AzDO agent pool scale set | `string` | n/a | yes |
| [vmss\_admin\_password](#input\_vmss\_admin\_password) | Admin password to log into the vmss instance | `string` | n/a | yes |
| [vmss\_admin\_user](#input\_vmss\_admin\_user) | Admin user account to log into the vmss instance | `string` | n/a | yes |
| [vnet\_address\_space](#input\_vnet\_address\_space) | The address space that is used by the virtual network. | `list(string)` | [ "10.0.0.0/16" ] | no |
