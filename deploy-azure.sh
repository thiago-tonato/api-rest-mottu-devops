#!/bin/bash

# 🏍️ Script de Deploy Automático - API de Rastreamento de Motos com UWB
# Este script automatiza o deploy completo da aplicação no Azure Container Instances

set -e  # Para o script se algum comando falhar

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para imprimir mensagens coloridas
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Variáveis de configuração
RESOURCE_GROUP="mottu-rg"
ACR_NAME="mottuqualitracker"
API_CONTAINER_NAME="mottu-api"
MYSQL_CONTAINER_NAME="mottu-mysql"
LOCATION="brazilsouth"
API_IMAGE_NAME="mottuapi"
API_IMAGE_TAG="1.0"
MYSQL_PASSWORD="QualiTracker123!"
MYSQL_DATABASE="mottu"
MYSQL_USER="mottuadmin"

# Gerar ID único para DNS
DNS_ID=$(date +%s | tail -c 6)
DNS_NAME="mottuapi-${DNS_ID}"

print_message "🚀 Iniciando deploy da API de Rastreamento de Motos com UWB"
print_message "📋 Configurações:"
print_message "   - Resource Group: ${RESOURCE_GROUP}"
print_message "   - ACR Name: ${ACR_NAME}"
print_message "   - DNS Name: ${DNS_NAME}"
print_message "   - Location: ${LOCATION}"

print_step "2. Criando Resource Group..."
az group create --name ${RESOURCE_GROUP} --location ${LOCATION} --output none
if [ $? -eq 0 ]; then
    print_message "✅ Resource Group '${RESOURCE_GROUP}' criado com sucesso"
else
    print_error "❌ Falha ao criar Resource Group"
    exit 1
fi

print_step "3. Criando Azure Container Registry..."
az acr create --resource-group ${RESOURCE_GROUP} --name ${ACR_NAME} --sku Basic --admin-enabled true --output none
if [ $? -eq 0 ]; then
    print_message "✅ ACR '${ACR_NAME}' criado com sucesso"
else
    print_error "❌ Falha ao criar ACR"
    exit 1
fi

print_step "4. Fazendo login no ACR..."
az acr login --name ${ACR_NAME} --output none
if [ $? -eq 0 ]; then
    print_message "✅ Login no ACR realizado com sucesso"
else
    print_error "❌ Falha no login do ACR"
    exit 1
fi

print_step "5. Buildando imagem Docker..."
print_message "🔨 Iniciando build da imagem Docker..."
docker build -t ${API_IMAGE_NAME}:local .
if [ $? -eq 0 ]; then
    print_message "✅ Imagem Docker buildada com sucesso"
else
    print_error "❌ Falha no build da imagem Docker"
    print_error "💡 Dica: Verifique se todas as dependências estão corretas no pom.xml"
    print_error "💡 Dica: Execute 'mvn clean package -DskipTests' localmente para testar"
    exit 1
fi

print_step "6. Taggeando e enviando imagem para ACR..."
docker tag ${API_IMAGE_NAME}:local ${ACR_NAME}.azurecr.io/${API_IMAGE_NAME}:${API_IMAGE_TAG}
docker push ${ACR_NAME}.azurecr.io/${API_IMAGE_NAME}:${API_IMAGE_TAG} --quiet
if [ $? -eq 0 ]; then
    print_message "✅ Imagem enviada para ACR com sucesso"
else
    print_error "❌ Falha ao enviar imagem para ACR"
    exit 1
fi

print_step "7. Criando container MySQL..."
az container create \
  --resource-group ${RESOURCE_GROUP} \
  --name ${MYSQL_CONTAINER_NAME} \
  --image mysql:8.0 \
  --cpu 1 --memory 1 \
  --os-type Linux \
  --ports 3306 \
  --environment-variables MYSQL_ROOT_PASSWORD="${MYSQL_PASSWORD}" MYSQL_DATABASE="${MYSQL_DATABASE}" \
  --ip-address Public \
  --output none

if [ $? -eq 0 ]; then
    print_message "✅ Container MySQL criado com sucesso"
else
    print_error "❌ Falha ao criar container MySQL"
    exit 1
fi

print_step "8. Obtendo IP do MySQL..."
MYSQL_IP=$(az container show -g ${RESOURCE_GROUP} -n ${MYSQL_CONTAINER_NAME} --query "ipAddress.ip" -o tsv)
if [ -z "$MYSQL_IP" ]; then
    print_error "❌ Falha ao obter IP do MySQL"
    exit 1
fi
print_message "✅ IP do MySQL: ${MYSQL_IP}"

print_step "9. Obtendo credenciais do ACR..."
ACR_USERNAME=$(az acr credential show --name ${ACR_NAME} --query "username" -o tsv)
ACR_PASSWORD=$(az acr credential show --name ${ACR_NAME} --query "passwords[0].value" -o tsv)

if [ -z "$ACR_USERNAME" ] || [ -z "$ACR_PASSWORD" ]; then
    print_error "❌ Falha ao obter credenciais do ACR"
    exit 1
fi
print_message "✅ Credenciais do ACR obtidas com sucesso"

print_step "10. Criando container da API..."
az container create \
  --resource-group ${RESOURCE_GROUP} \
  --name ${API_CONTAINER_NAME} \
  --image ${ACR_NAME}.azurecr.io/${API_IMAGE_NAME}:${API_IMAGE_TAG} \
  --cpu 1 --memory 1.5 \
  --os-type Linux \
  --ports 8080 \
  --dns-name-label ${DNS_NAME} \
  --environment-variables \
     SPRING_PROFILES_ACTIVE=production \
     SPRING_DATASOURCE_URL="jdbc:mysql://${MYSQL_IP}:3306/${MYSQL_DATABASE}?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC" \
     SPRING_DATASOURCE_USERNAME="${MYSQL_USER}" \
     SPRING_DATASOURCE_PASSWORD="${MYSQL_PASSWORD}" \
     SPRING_FLYWAY_URL="jdbc:mysql://${MYSQL_IP}:3306/${MYSQL_DATABASE}?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC" \
     SPRING_FLYWAY_USER="${MYSQL_USER}" \
     SPRING_FLYWAY_PASSWORD="${MYSQL_PASSWORD}" \
  --registry-login-server ${ACR_NAME}.azurecr.io \
  --registry-username ${ACR_USERNAME} \
  --registry-password "${ACR_PASSWORD}" \
  --ip-address Public \
  --output none

if [ $? -eq 0 ]; then
    print_message "✅ Container da API criado com sucesso"
else
    print_error "❌ Falha ao criar container da API"
    exit 1
fi

print_step "11. Obtendo informações de acesso..."
API_FQDN=$(az container show -g ${RESOURCE_GROUP} -n ${API_CONTAINER_NAME} --query "ipAddress.fqdn" -o tsv)
API_IP=$(az container show -g ${RESOURCE_GROUP} -n ${API_CONTAINER_NAME} --query "ipAddress.ip" -o tsv)

if [ -z "$API_FQDN" ]; then
    print_error "❌ Falha ao obter FQDN da API"
    exit 1
fi

print_message "🎉 Deploy concluído com sucesso!"
echo ""
print_message "📋 Informações de Acesso:"
print_message "   🌐 API URL: http://${API_FQDN}:8080"
print_message "   🗄️ MySQL IP: ${MYSQL_IP}:3306"
print_message "   👤 MySQL User: root"
print_message "   🔑 MySQL Password: ${MYSQL_PASSWORD}"
print_message "   📊 MySQL Database: ${MYSQL_DATABASE}"
echo ""
print_message "🔧 Comandos úteis:"
print_message "   Ver logs da API: az container logs --resource-group ${RESOURCE_GROUP} --name ${API_CONTAINER_NAME}"
print_message "   Ver logs do MySQL: az container logs --resource-group ${RESOURCE_GROUP} --name ${MYSQL_CONTAINER_NAME}"
print_message "   Ver status dos containers: az container list --resource-group ${RESOURCE_GROUP} --output table"
echo ""
print_message "🧪 Teste a API:"
print_message "   curl http://${API_FQDN}:8080/api/sensores"
print_message "   curl http://${API_FQDN}:8080/api/motos"
echo ""
print_warning "⏳ Aguarde alguns minutos para a aplicação inicializar completamente antes de testar!"
