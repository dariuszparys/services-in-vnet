#!/bin/bash

set -ex

NETWORK_INTERFACE_ID=$(az network private-endpoint show \
  --name $PRIVATE_ENDPOINT_NAME \
  --resource-group $RESOURCE_GROUP \
  --query 'networkInterfaces[0].id' \
  --output tsv)

WORKSPACE_PRIVATE_IP=$(az network nic show \
  --ids $NETWORK_INTERFACE_ID \
  --query "ipConfigurations[?privateLinkConnectionProperties.requiredMemberName=='default'].privateIpAddress" \
  --output tsv)

NOTEBOOK_PRIVATE_IP=$(az network nic show \
  --ids $NETWORK_INTERFACE_ID \
  --query "ipConfigurations[?privateLinkConnectionProperties.requiredMemberName=='notebook'].privateIpAddress" \
  --output tsv)

# An FQDN is associated with each IP address in the IP configurations
WORKSPACE_FQDN1=$(az network nic show \
  --ids $NETWORK_INTERFACE_ID \
  --query "ipConfigurations[?privateLinkConnectionProperties.requiredMemberName=='default'].privateLinkConnectionProperties.fqdns[0]" \
  --output tsv)

A1=$(echo ${WORKSPACE_FQDN1} | sed -e 's/\(.api.azureml.ms\)*$//g')

WORKSPACE_FQDN2=$(az network nic show \
  --ids $NETWORK_INTERFACE_ID \
  --query "ipConfigurations[?privateLinkConnectionProperties.requiredMemberName=='default'].privateLinkConnectionProperties.fqdns[1]" \
  --output tsv)

A2=$(echo ${WORKSPACE_FQDN2} | sed -e 's/\(.api.azureml.ms\)*$//g')

NOTEBOOK_FQDN=$(az network nic show \
  --ids $NETWORK_INTERFACE_ID \
  --query "ipConfigurations[?privateLinkConnectionProperties.requiredMemberName=='notebook'].privateLinkConnectionProperties.fqdns" \
  --output tsv)

A3=$(echo ${NOTEBOOK_FQDN} | sed -e 's/\(.notebooks.azure.net\)*$//g')

az network private-dns record-set a create \
  --name $A1 \
  --zone-name privatelink.api.azureml.ms \
  --resource-group $RESOURCE_GROUP

az network private-dns record-set a create \
  --name $A2 \
  --zone-name privatelink.api.azureml.ms \
  --resource-group $RESOURCE_GROUP

az network private-dns record-set a create \
  --name $A3  \
  --zone-name privatelink.notebooks.azure.net \
  --resource-group $RESOURCE_GROUP  

az network private-dns record-set a add-record \
  --record-set-name $A1 \
  --zone-name privatelink.api.azureml.ms \
  --resource-group $RESOURCE_GROUP \
  --ipv4-address $WORKSPACE_PRIVATE_IP

az network private-dns record-set a add-record \
  --record-set-name $A2 \
  --zone-name privatelink.api.azureml.ms \
  --resource-group $RESOURCE_GROUP \
  --ipv4-address $WORKSPACE_PRIVATE_IP

az network private-dns record-set a add-record \
  --record-set-name $A3 \
  --zone-name privatelink.notebooks.azure.net \
  --resource-group $RESOURCE_GROUP \
  --ipv4-address $NOTEBOOK_PRIVATE_IP
