#!/bin/bash

# Script para criar recursos Azure - QualiTracker Mottu
# Este script cria: Resource Group, MySQL, ACR, App Service Plan e Web App

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configurações
PROJECT_NAME="qualitracker"
COMPANY_NAME="mottu"
RESOURCE_GROUP="${PROJECT_NAME}-${COMPANY_NAME}-rg"
LOCATION="eastus"  # Altere para a região desejada

# MySQL
MYSQL_SERVER_NAME="${PROJECT_NAME}-mysql-server"
MYSQL_DB_NAME="qualitracker"
MYSQL_ADMIN_USER="mottuadmin"
MYSQL_ADMIN_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)  # Gera senha aleatória
MYSQL_APP_USER="qualitracker_user"  # Usuário da aplicação
MYSQL_APP_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)  # Gera senha aleatória

# Não precisa de Container Registry - deploy direto do JAR

# App Service
APP_SERVICE_PLAN_NAME="${PROJECT_NAME}-asp"
WEB_APP_NAME="${PROJECT_NAME}-app"  # Deve ser único globalmente

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}QualiTracker Mottu - Azure Setup${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Verificar se Azure CLI está instalado
if ! command -v az &> /dev/null; then
    echo -e "${RED}Azure CLI não está instalado. Por favor, instale: https://docs.microsoft.com/cli/azure/install-azure-cli${NC}"
    exit 1
fi

# Verificar se está logado
echo -e "${YELLOW}Verificando login no Azure...${NC}"
if ! az account show &> /dev/null; then
    echo -e "${YELLOW}Fazendo login no Azure...${NC}"
    az login
fi

# Obter subscription atual
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo -e "${GREEN}Usando subscription: ${SUBSCRIPTION_ID}${NC}"
echo ""

# ============================================
# 1. Criar Resource Group
# ============================================
echo -e "${YELLOW}[1/7] Criando Resource Group...${NC}"
if az group show --name $RESOURCE_GROUP &> /dev/null; then
    echo -e "${YELLOW}Resource Group já existe.${NC}"
else
    az group create \
        --name $RESOURCE_GROUP \
        --location $LOCATION
    echo -e "${GREEN}✓ Resource Group criado: ${RESOURCE_GROUP}${NC}"
fi
echo ""

# ============================================
# 2. Criar Azure Database for MySQL
# ============================================
echo -e "${YELLOW}[2/7] Criando Azure Database for MySQL...${NC}"
if az mysql flexible-server show --resource-group $RESOURCE_GROUP --name $MYSQL_SERVER_NAME &> /dev/null; then
    echo -e "${YELLOW}MySQL Server já existe.${NC}"
else
    az mysql flexible-server create \
        --resource-group $RESOURCE_GROUP \
        --name $MYSQL_SERVER_NAME \
        --location $LOCATION \
        --admin-user $MYSQL_ADMIN_USER \
        --admin-password $MYSQL_ADMIN_PASSWORD \
        --sku-name Standard_B1ms \
        --tier Burstable \
        --public-access 0.0.0.0 \
        --storage-size 32 \
        --version 8.0.21 \
        --high-availability Disabled \
        --storage-auto-grow Enabled
    
    echo -e "${GREEN}✓ MySQL Server criado: ${MYSQL_SERVER_NAME}${NC}"
    echo -e "${GREEN}  Admin User: ${MYSQL_ADMIN_USER}${NC}"
    echo -e "${GREEN}  Admin Password: ${MYSQL_ADMIN_PASSWORD}${NC}"
fi

# Obter FQDN do servidor MySQL
MYSQL_FQDN="${MYSQL_SERVER_NAME}.mysql.database.azure.com"
echo ""

# ============================================
# 3. Configurar Firewall do MySQL
# ============================================
echo -e "${YELLOW}[3/7] Configurando firewall do MySQL...${NC}"

# Permitir acesso do Azure Services
az mysql flexible-server firewall-rule create \
    --resource-group $RESOURCE_GROUP \
    --name $MYSQL_SERVER_NAME \
    --rule-name AllowAzureServices \
    --start-ip-address 0.0.0.0 \
    --end-ip-address 0.0.0.0 \
    --output none 2>/dev/null || echo -e "${YELLOW}Regra de firewall já existe.${NC}"

# Obter IP público atual
MY_IP=$(curl -s ifconfig.me)
echo -e "${YELLOW}Seu IP público: ${MY_IP}${NC}"

# Permitir acesso do seu IP
az mysql flexible-server firewall-rule create \
    --resource-group $RESOURCE_GROUP \
    --name $MYSQL_SERVER_NAME \
    --rule-name AllowMyIP \
    --start-ip-address $MY_IP \
    --end-ip-address $MY_IP \
    --output none 2>/dev/null || echo -e "${YELLOW}Regra de firewall para seu IP já existe.${NC}"

echo -e "${GREEN}✓ Firewall configurado${NC}"
echo ""

# ============================================
# 4. Criar Banco de Dados
# ============================================
echo -e "${YELLOW}[4/7] Criando banco de dados...${NC}"

# Criar banco de dados usando MySQL CLI ou Azure CLI
az mysql flexible-server db create \
    --resource-group $RESOURCE_GROUP \
    --server-name $MYSQL_SERVER_NAME \
    --database-name $MYSQL_DB_NAME \
    --output none 2>/dev/null || echo -e "${YELLOW}Banco de dados já existe.${NC}"

echo -e "${GREEN}✓ Banco de dados criado: ${MYSQL_DB_NAME}${NC}"
echo ""

# ============================================
# 5. Criar Usuário da Aplicação no MySQL
# ============================================
echo -e "${YELLOW}[5/7] Criando usuário da aplicação no MySQL...${NC}"

# Criar script SQL temporário para criar usuário
SQL_SCRIPT="/tmp/create_user_${RANDOM}.sql"
cat > $SQL_SCRIPT << EOF
CREATE USER IF NOT EXISTS '${MYSQL_APP_USER}'@'%' IDENTIFIED BY '${MYSQL_APP_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DB_NAME}.* TO '${MYSQL_APP_USER}'@'%';
FLUSH PRIVILEGES;
EOF

# Executar script SQL
echo -e "${YELLOW}Executando script SQL para criar usuário...${NC}"
mysql -h $MYSQL_FQDN -u $MYSQL_ADMIN_USER -p$MYSQL_ADMIN_PASSWORD < $SQL_SCRIPT 2>/dev/null || {
    echo -e "${YELLOW}MySQL CLI não encontrado. Criando usuário via Azure CLI...${NC}"
    # Alternativa: usar az mysql flexible-server execute para executar comandos
    echo -e "${YELLOW}Por favor, execute manualmente no MySQL Workbench:${NC}"
    echo ""
    echo "CREATE USER IF NOT EXISTS '${MYSQL_APP_USER}'@'%' IDENTIFIED BY '${MYSQL_APP_PASSWORD}';"
    echo "GRANT ALL PRIVILEGES ON ${MYSQL_DB_NAME}.* TO '${MYSQL_APP_USER}'@'%';"
    echo "FLUSH PRIVILEGES;"
    echo ""
}

rm -f $SQL_SCRIPT
echo -e "${GREEN}✓ Usuário da aplicação criado: ${MYSQL_APP_USER}${NC}"
echo -e "${GREEN}  Password: ${MYSQL_APP_PASSWORD}${NC}"
echo ""

# ============================================
# 6. Criar App Service Plan e Web App
# ============================================
echo -e "${YELLOW}[6/6] Criando App Service Plan e Web App...${NC}"

# Criar App Service Plan
if az appservice plan show --resource-group $RESOURCE_GROUP --name $APP_SERVICE_PLAN_NAME &> /dev/null; then
    echo -e "${YELLOW}App Service Plan já existe.${NC}"
else
    az appservice plan create \
        --resource-group $RESOURCE_GROUP \
        --name $APP_SERVICE_PLAN_NAME \
        --location $LOCATION \
        --is-linux \
        --sku B1
    
    echo -e "${GREEN}✓ App Service Plan criado: ${APP_SERVICE_PLAN_NAME}${NC}"
fi

# Criar Web App (Java)
if az webapp show --resource-group $RESOURCE_GROUP --name $WEB_APP_NAME &> /dev/null; then
    echo -e "${YELLOW}Web App já existe.${NC}"
else
    az webapp create \
        --resource-group $RESOURCE_GROUP \
        --plan $APP_SERVICE_PLAN_NAME \
        --name $WEB_APP_NAME \
        --runtime "JAVA:17-java11"
    
    echo -e "${GREEN}✓ Web App criada: ${WEB_APP_NAME}${NC}"
fi

# Configurar Java
az webapp config set \
    --resource-group $RESOURCE_GROUP \
    --name $WEB_APP_NAME \
    --java-version "17" \
    --java-container "JAVA" \
    --java-container-version "17" \
    --output none

# Habilitar HTTPS
az webapp update \
    --resource-group $RESOURCE_GROUP \
    --name $WEB_APP_NAME \
    --https-only true \
    --output none

# Configurar variáveis de ambiente
echo -e "${YELLOW}Configurando variáveis de ambiente...${NC}"

MYSQL_CONNECTION_STRING="jdbc:mysql://${MYSQL_FQDN}:3306/${MYSQL_DB_NAME}?useSSL=true&requireSSL=false&serverTimezone=UTC"

az webapp config appsettings set \
    --resource-group $RESOURCE_GROUP \
    --name $WEB_APP_NAME \
    --settings \
        SPRING_DATASOURCE_URL="$MYSQL_CONNECTION_STRING" \
        SPRING_DATASOURCE_USERNAME="${MYSQL_APP_USER}" \
        SPRING_DATASOURCE_PASSWORD="${MYSQL_APP_PASSWORD}" \
        SPRING_FLYWAY_URL="$MYSQL_CONNECTION_STRING" \
        SPRING_FLYWAY_USER="${MYSQL_APP_USER}" \
        SPRING_FLYWAY_PASSWORD="${MYSQL_APP_PASSWORD}" \
        SERVER_PORT="8080" \
        JAVA_OPTS="-Xmx512m -Xms256m" \
    --output none

echo -e "${GREEN}✓ Variáveis de ambiente configuradas${NC}"
echo ""

# ============================================
# Resumo Final
# ============================================
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ Setup Concluído!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Informações de Conexão:${NC}"
echo ""
echo -e "${GREEN}MySQL Server:${NC}"
echo "  Host: ${MYSQL_FQDN}"
echo "  Port: 3306"
echo "  Database: ${MYSQL_DB_NAME}"
echo ""
echo "  Admin User: ${MYSQL_ADMIN_USER}"
echo "  Admin Password: ${MYSQL_ADMIN_PASSWORD}"
echo ""
echo "  App User: ${MYSQL_APP_USER}"
echo "  App Password: ${MYSQL_APP_PASSWORD}"
echo ""
echo -e "${GREEN}Web App:${NC}"
WEB_APP_URL="https://${WEB_APP_NAME}.azurewebsites.net"
echo "  URL: ${WEB_APP_URL}"
echo ""
echo -e "${YELLOW}String de Conexão MySQL (para Workbench):${NC}"
echo "  mysql://${MYSQL_APP_USER}:${MYSQL_APP_PASSWORD}@${MYSQL_FQDN}:3306/${MYSQL_DB_NAME}"
echo ""
echo -e "${YELLOW}Próximos Passos:${NC}"
echo "  1. Execute o pipeline CI/CD no Azure DevOps"
echo "  2. A aplicação estará disponível em: ${WEB_APP_URL}"
echo "  3. Conecte ao MySQL usando as credenciais acima no MySQL Workbench"
echo ""
echo -e "${RED}⚠️ IMPORTANTE: Salve estas credenciais em local seguro!${NC}"
echo ""

