# Terraform VNet for Azure Function and App Services Sample

To run the sample without VNet

```bash
terraform init
terraform plan -out=plan.tfplan
terraform apply plan.tfplan
```

To run the sample with VNet

```bash
terraform init
terraform plan -out=plan.tfplan -var='enable_vnet=true'
terraform apply plan.tfplan
```

## Resources that will be created

tbd
