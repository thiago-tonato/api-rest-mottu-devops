#!/bin/bash

# Script para preparar recursos Azure necessários para o pipeline CI/CD
# Cria/atualiza: Resource Group e Azure Container Registry (com imagem base do MySQL)

set -euo pipefail

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# Configurações básicas
PROJECT_NAME="qualitracker"
COMPANY_NAME="mottu"
RESOURCE_GROUP="${PROJECT_NAME}-${COMPANY_NAME}-rg"
LOCATION="brazilsouth"  # Ajuste se desejar outra região suportada por ACI

# Azure Container Registry
ACR_NAME="${PROJECT_NAME}acr"
REGISTRY_LOGIN_SERVER="${ACR_NAME}.azurecr.io"
APP_IMAGE_REPO="${PROJECT_NAME}-app"
DB_IMAGE_REPO="${PROJECT_NAME}-mysql"
DB_IMAGE_TAG="8.0"

# Funções auxiliares
print_step() {
  echo -e "${YELLOW}$1${NC}"
}

print_success() {
  echo -e "${GREEN}✓ $1${NC}"
}

wait_for_acr_ready() {
  print_step "Aguardando ACR concluir provisionamento..."
  for attempt in {1..30}; do
    STATE=$(az acr show --name "$ACR_NAME" --query "provisioningState" -o tsv 2>/dev/null || echo "Pending")
    if [[ "$STATE" == "Succeeded" ]]; then
      print_success "Provisionamento concluído."
      break
    fi
    sleep 10
    if [[ $attempt -eq 30 ]]; then
      echo -e "${RED}❌ ACR não ficou pronto após aguardar 5 minutos.${NC}"
      exit 1
    fi
  done

  REGISTRY_LOGIN_SERVER=$(az acr show --name "$ACR_NAME" --query "loginServer" -o tsv)

  if command -v nslookup >/dev/null 2>&1; then
    print_step "Aguardando propagação DNS do ACR..."
    for attempt in {1..30}; do
      if nslookup "$REGISTRY_LOGIN_SERVER" >/dev/null 2>&1; then
        print_success "DNS do ACR resolvido."
        break
      fi
      sleep 5
      if [[ $attempt -eq 30 ]]; then
        echo -e "${RED}❌ DNS do ACR não resolveu após aguardar 150 segundos.${NC}"
        exit 1
      fi
    done
  else
    print_step "nslookup não disponível; aguardando 30 segundos para propagação DNS..."
    sleep 30
  fi
}

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}QualiTracker Mottu - Azure Infra Setup${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Verificar Azure CLI
if ! command -v az >/dev/null 2>&1; then
  echo -e "${RED}Azure CLI não está instalado. Instale em: https://learn.microsoft.com/cli/azure/install-azure-cli${NC}"
  exit 1
fi

# Verificar login no Azure
print_step "Verificando login no Azure..."
if ! az account show >/dev/null 2>&1; then
  az login
fi

SUBSCRIPTION_ID=$(az account show --query id -o tsv)
print_success "Usando subscription: ${SUBSCRIPTION_ID}"

echo ""

# 1. Resource Group
print_step "[1/3] Garantindo Resource Group..."
if az group show --name "$RESOURCE_GROUP" >/dev/null 2>&1; then
  print_step "Resource Group já existe: ${RESOURCE_GROUP}"
else
  az group create --name "$RESOURCE_GROUP" --location "$LOCATION" >/dev/null
  print_success "Resource Group criado: ${RESOURCE_GROUP}"
fi

echo ""

# 2. Azure Container Registry
print_step "[2/3] Garantindo Azure Container Registry (${ACR_NAME})..."
if az acr show --name "$ACR_NAME" >/dev/null 2>&1; then
  print_step "ACR já existe, reutilizando."
  wait_for_acr_ready
else
  az acr create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$ACR_NAME" \
    --sku Basic \
    --location "$LOCATION" \
    --admin-enabled true >/dev/null
  print_success "ACR criado: ${REGISTRY_LOGIN_SERVER}"
  wait_for_acr_ready
fi

echo ""

# 3. Importar imagem base do MySQL
print_step "[3/3] Garantindo imagem MySQL (${DB_IMAGE_REPO}:${DB_IMAGE_TAG}) no ACR..."
MYSQL_TAG_EXISTS=$(az acr repository show-tags --name "$ACR_NAME" --repository "$DB_IMAGE_REPO" --query "contains(@, '${DB_IMAGE_TAG}')" -o tsv 2>/dev/null || echo false)
if [[ "$MYSQL_TAG_EXISTS" == "true" ]]; then
  print_step "Imagem MySQL já existe no ACR."
else
  az acr import \
    --name "$ACR_NAME" \
    --source "docker.io/library/mysql:${DB_IMAGE_TAG}" \
    --image "${DB_IMAGE_REPO}:${DB_IMAGE_TAG}" >/dev/null
  print_success "Imagem MySQL importada para o ACR"
fi

echo ""
print_success "Infraestrutura preparada!"

echo ""
print_step "Próximos passos:"
echo "  • Configure as variáveis no Azure DevOps (veja README/AZURE_SETUP)."
print_step "  • Execute o pipeline para construir a imagem da aplicação e criar/atualizar o container group."

print_step "Recursos provisionados:"
echo "  • Resource Group: ${RESOURCE_GROUP}"
echo "  • Azure Container Registry: ${REGISTRY_LOGIN_SERVER}"
echo "  • Imagem base MySQL: ${DB_IMAGE_REPO}:${DB_IMAGE_TAG}"

