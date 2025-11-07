#!/bin/bash

# Script para criar recursos Azure usando contêineres no Azure Container Instances
# Cria: Resource Group, Azure Container Registry, imagens da aplicação e do MySQL
# e um Container Group com dois contêineres (app + banco de dados)

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

# Configurações de nomes e imagens
UNIQUE_SUFFIX=$(openssl rand -hex 3 | tr '[:upper:]' '[:lower:]')
ACR_NAME="${PROJECT_NAME}acr${UNIQUE_SUFFIX}"
REGISTRY_LOGIN_SERVER="${ACR_NAME}.azurecr.io"
APP_IMAGE_REPO="${PROJECT_NAME}-app"
APP_IMAGE_TAG="latest"
DB_IMAGE_REPO="${PROJECT_NAME}-mysql"
DB_IMAGE_TAG="8.0"
APP_IMAGE_FULL="${REGISTRY_LOGIN_SERVER}/${APP_IMAGE_REPO}:${APP_IMAGE_TAG}"
DB_IMAGE_FULL="${REGISTRY_LOGIN_SERVER}/${DB_IMAGE_REPO}:${DB_IMAGE_TAG}"

# Container Group
CONTAINER_GROUP_NAME="${PROJECT_NAME}-aci"
APP_CONTAINER_NAME="${PROJECT_NAME}-app"
MYSQL_CONTAINER_NAME="${PROJECT_NAME}-mysql"
DNS_LABEL="${PROJECT_NAME}-${UNIQUE_SUFFIX}"

# Banco de dados
MYSQL_DB_NAME="qualitracker"
MYSQL_APP_USER="qualitracker_user"
MYSQL_APP_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
MYSQL_ROOT_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)

APP_CONNECTION_STRING="jdbc:mysql://127.0.0.1:3306/${MYSQL_DB_NAME}?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC"

# Função auxiliar
print_step() {
  echo -e "${YELLOW}$1${NC}"
}

print_success() {
  echo -e "${GREEN}✓ $1${NC}"
}

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}QualiTracker Mottu - Azure Container Setup${NC}"
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

# 1. Resource Group
print_step "[1/6] Criando Resource Group..."
if az group show --name "$RESOURCE_GROUP" >/dev/null 2>&1; then
  print_step "Resource Group já existe, reutilizando."
else
  az group create --name "$RESOURCE_GROUP" --location "$LOCATION" >/dev/null
  print_success "Resource Group criado: ${RESOURCE_GROUP}"
fi

echo ""

# 2. Azure Container Registry
print_step "[2/6] Criando Azure Container Registry (${ACR_NAME})..."
if az acr show --name "$ACR_NAME" >/dev/null 2>&1; then
  print_step "ACR já existe, reutilizando."
else
  az acr create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$ACR_NAME" \
    --sku Basic \
    --location "$LOCATION" \
    --admin-enabled true >/dev/null
  print_success "ACR criado: ${REGISTRY_LOGIN_SERVER}"
fi

echo ""

# 3. Build da imagem da aplicação
print_step "[3/6] Construindo imagem da aplicação e enviando para o ACR..."
az acr build \
  --registry "$ACR_NAME" \
  --image "${APP_IMAGE_REPO}:${APP_IMAGE_TAG}" \
  . >/dev/null
print_success "Imagem da aplicação publicada: ${APP_IMAGE_FULL}"

echo ""

# 4. Importar imagem do MySQL oficial para o ACR
print_step "[4/6] Importando imagem MySQL (${DB_IMAGE_FULL}) para o ACR..."
az acr import \
  --name "$ACR_NAME" \
  --source "docker.io/library/mysql:8.0" \
  --image "${DB_IMAGE_REPO}:${DB_IMAGE_TAG}" \
  --force >/dev/null
print_success "Imagem do banco disponível no ACR"

echo ""

# 5. Recuperar credenciais do ACR
print_step "[5/6] Coletando credenciais do ACR..."
ACR_USERNAME=$(az acr credential show --name "$ACR_NAME" --query username -o tsv)
ACR_PASSWORD=$(az acr credential show --name "$ACR_NAME" --query passwords[0].value -o tsv)
print_success "Credenciais do ACR prontas."

echo ""

# 6. Provisionar Container Group com app + MySQL
print_step "[6/6] Provisionando Azure Container Instances..."
ACI_TEMPLATE=$(mktemp 2>/dev/null || mktemp.exe 2>/dev/null || echo "${TMPDIR:-/tmp}/aci-${RANDOM}.json")
trap 'rm -f "$ACI_TEMPLATE"' EXIT

cat >"$ACI_TEMPLATE" <<EOF
{
  "name": "${CONTAINER_GROUP_NAME}",
  "location": "${LOCATION}",
  "properties": {
    "containers": [
      {
        "name": "${APP_CONTAINER_NAME}",
        "properties": {
          "image": "${APP_IMAGE_FULL}",
          "ports": [
            {
              "port": 8080
            }
          ],
          "environmentVariables": [
            { "name": "SERVER_PORT", "value": "8080" },
            { "name": "DB_HOST", "value": "127.0.0.1" },
            { "name": "DB_PORT", "value": "3306" },
            { "name": "SPRING_DATASOURCE_URL", "value": "${APP_CONNECTION_STRING}" },
            { "name": "SPRING_DATASOURCE_USERNAME", "value": "${MYSQL_APP_USER}" },
            { "name": "SPRING_DATASOURCE_PASSWORD", "secureValue": "${MYSQL_APP_PASSWORD}" },
            { "name": "SPRING_FLYWAY_URL", "value": "${APP_CONNECTION_STRING}" },
            { "name": "SPRING_FLYWAY_USER", "value": "${MYSQL_APP_USER}" },
            { "name": "SPRING_FLYWAY_PASSWORD", "secureValue": "${MYSQL_APP_PASSWORD}" },
            { "name": "JAVA_OPTS", "value": "-Xms256m -Xmx512m" }
          ],
          "resources": {
            "requests": {
              "cpu": 1.0,
              "memoryInGB": 1.5
            }
          }
        }
      },
      {
        "name": "${MYSQL_CONTAINER_NAME}",
        "properties": {
          "image": "${DB_IMAGE_FULL}",
          "ports": [
            {
              "port": 3306
            }
          ],
          "environmentVariables": [
            { "name": "MYSQL_DATABASE", "value": "${MYSQL_DB_NAME}" },
            { "name": "MYSQL_USER", "value": "${MYSQL_APP_USER}" },
            { "name": "MYSQL_PASSWORD", "secureValue": "${MYSQL_APP_PASSWORD}" },
            { "name": "MYSQL_ROOT_PASSWORD", "secureValue": "${MYSQL_ROOT_PASSWORD}" }
          ],
          "resources": {
            "requests": {
              "cpu": 1.0,
              "memoryInGB": 1.5
            }
          }
        }
      }
    ],
    "osType": "Linux",
    "restartPolicy": "Always",
    "imageRegistryCredentials": [
      {
        "server": "${REGISTRY_LOGIN_SERVER}",
        "username": "${ACR_USERNAME}",
        "password": "${ACR_PASSWORD}"
      }
    ],
    "ipAddress": {
      "type": "Public",
      "dnsNameLabel": "${DNS_LABEL}",
      "ports": [
        {
          "protocol": "TCP",
          "port": 8080
        }
      ]
    }
  }
}
EOF

az container create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$CONTAINER_GROUP_NAME" \
  --file "$ACI_TEMPLATE" >/dev/null

print_success "Container group criado: ${CONTAINER_GROUP_NAME}"

echo ""

APP_URL="http://${DNS_LABEL}.${LOCATION}.azurecontainer.io:8080"

# Resumo final
print_success "Setup concluído!"
echo ""
print_step "Informações importantes:"
echo "  • Resource Group: ${RESOURCE_GROUP}"
echo "  • Azure Container Registry: ${REGISTRY_LOGIN_SERVER}"
echo "  • Imagem da aplicação: ${APP_IMAGE_FULL}"
echo "  • Imagem do MySQL: ${DB_IMAGE_FULL}"
echo "  • Container Group: ${CONTAINER_GROUP_NAME}"
echo "  • URL da aplicação: ${APP_URL}"
echo ""
print_step "Credenciais geradas:"
echo "  • Usuário banco: ${MYSQL_APP_USER}"
echo "  • Senha banco: ${MYSQL_APP_PASSWORD}"
echo "  • Senha root MySQL: ${MYSQL_ROOT_PASSWORD}"
echo ""
print_step "Comandos úteis:"
echo "  az acr login --name ${ACR_NAME}"
echo "  az container logs --resource-group ${RESOURCE_GROUP} --name ${CONTAINER_GROUP_NAME} --container ${APP_CONTAINER_NAME}"
echo "  az container exec --resource-group ${RESOURCE_GROUP} --name ${CONTAINER_GROUP_NAME} --container ${MYSQL_CONTAINER_NAME} --exec-command \"mysql -u${MYSQL_APP_USER} -p${MYSQL_APP_PASSWORD} ${MYSQL_DB_NAME}\""
echo ""
echo -e "${RED}⚠️ Salve as senhas em local seguro. Elas não serão exibidas novamente.${NC}"

