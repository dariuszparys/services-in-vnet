# [WIP] Terraform VNet for Azure Function and App Services Sample

[![CI](https://github.com/dariuszparys/services-in-vnet/actions/workflows/validate-terraform.yml/badge.svg)](https://github.com/dariuszparys/services-in-vnet/actions/workflows/validate-terraform.yml)

This sample is demonstrating the following infrastructure components

todo: insert architecture picture here

Further it has two sample applications that will be deployed together with the terraform
apply command. You find the applications under the `src` directory and both are written
in Python.

## Run the sample

In order to use the sample as it is we go with a two step approach. This is needed in order
to deploy the build docker container for the sample applications that will be build and pushed
to the newly created Azure Container Registry.

### Terraform apply without VNet

Running the following commands

```bash
terraform init
terraform plan -out=plan.tfplan
terraform apply plan.tfplan
```

will provision the following components

- Azure Container Registry
- Azure Application Insights
- Azure Service Plan with Premium P1v2 SKU
- Azure Function App
- Azure App Service App
- Azure Storage Account

### Terraform apply with VNet

Once it was deployed without VNet a second terraform plan with the proper
variable definition can be triggered in order to lock down the resources into
a VNet and make them only accessible through the Application Gateway Public 
endpoint.

To enable the VNet simply run

```bash
terraform plan -out=plan.tfplan -var='enable_vnet=true'
terraform apply plan.tfplan
```

and it will provision in addition the following components

- Azure Virtual Network
- Azure Application Gateway (Standard_V2)

tbd
