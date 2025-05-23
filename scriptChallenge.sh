#!/bin/bash

# Variáveis
RESOURCE_GROUP="rg-challenge"
LOCATION="eastus2"
VM_NAME="vm-mottu"
IMAGE="Canonical:UbuntuServer:18.04-LTS:latest"

SIZE="Standard_D2s_v3"
ADMIN_USERNAME="rm99404"
ADMIN_PASSWORD="Fiap@2tdsvms"
DISK_SKU="StandardSSD_LRS"

# Criar grupo de recursos
echo "Criando grupo de recursos: $RESOURCE_GROUP..."
az group create --name $RESOURCE_GROUP --location $LOCATION

# Criar Network Security Group (NSG)
echo "Criando Network Security Group: ${VM_NAME}-nsg..."
az network nsg create \
  --resource-group $RESOURCE_GROUP \
  --name ${VM_NAME}-nsg

# Adicionar regra de inbound para SSH (Porta 22)
echo "Adicionando regra de inbound para SSH (Porta 22)..."
az network nsg rule create \
  --resource-group $RESOURCE_GROUP \
  --nsg-name ${VM_NAME}-nsg \
  --name SSH-Rule \
  --protocol Tcp \
  --direction Inbound \
  --priority 100 \
  --source-address-prefixes '*' \
  --source-port-ranges '*' \
  --destination-address-prefixes '*' \
  --destination-port-ranges 22 \
  --access Allow

# Criar a VM e associar o NSG à interface de rede
echo "Criando a máquina virtual: $VM_NAME e associando o NSG..."
az vm create \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --image $IMAGE \
  --size $SIZE \
  --authentication-type password \
  --admin-username $ADMIN_USERNAME \
  --admin-password $ADMIN_PASSWORD \
  --storage-sku $DISK_SKU \
  --public-ip-sku Basic \
  --nsg ${VM_NAME}-nsg

# Abrir a porta 8080 para a API
echo "Abrindo porta 8080 para a API..."
az vm open-port --port 8080 --resource-group $RESOURCE_GROUP --name $VM_NAME

echo "✅   Provisionamento completo!"
