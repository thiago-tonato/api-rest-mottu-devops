# 🏍️ API de Rastreamento de Motos com UWB - Mottu

API REST desenvolvida em Java Spring Boot para gerenciamento de motos com tecnologia UWB (Ultra-Wideband) para rastreamento preciso.

## 🚀 Deploy no Azure Container Instances

### Pré-requisitos

- Docker instalado
- Azure CLI instalado
- PowerShell (Windows) ou Terminal (Linux/Mac)

### 🌐 2. Login no Azure e criação do Resource Group

```powershell
az login
az group create --name mottu-rg --location brazilsouth
```

### 📦 3. Azure Container Registry (ACR)

Crie um registro de imagens (o nome deve ser único no mundo):

```powershell
az acr create --resource-group mottu-rg --name mottuacr01 --sku Basic --admin-enabled true
```

Verifique o login server retornado (ex.: mottuacr01.azurecr.io).

### 🐳 4. Build e Push da Imagem Java Spring Boot

No diretório onde está o Dockerfile:

```powershell
docker build -t mottuapi:local .
az acr login --name mottuacr01
docker tag mottuapi:local mottuacr01.azurecr.io/mottuapi:1.0
docker push mottuacr01.azurecr.io/mottuapi:1.0
```

### 🗄️ 5. Banco de Dados MySQL no ACI

Crie o container com MySQL 8.0:

```powershell
az container create `
  --resource-group mottu-rg `
  --name mottu-mysql `
  --image mysql:8.0 `
  --cpu 1 --memory 1 `
  --os-type Linux `
  --ports 3306 `
  --environment-variables MYSQL_ROOT_PASSWORD="QualiTracker123!" MYSQL_DATABASE=mottu `
  --ip-address Public
```

Pegue o IP público para uso no próximo passo:

```powershell
az container show -g mottu-rg -n mottu-mysql --query "ipAddress.ip" -o tsv
```

Anote o IP, por exemplo: `00.000.000.00`

### ⚙️ 6. Deploy da API Java Spring Boot no ACI

Obtenha as credenciais do ACR:

```powershell
az acr credential show --name mottuacr01
```

Crie a instância da sua API, ajustando `--dns-name-label` para algo único no Azure:

```powershell
az container create `
  --resource-group mottu-rg `
  --name mottu-api `
  --image mottuacr01.azurecr.io/mottuapi:1.0 `
  --cpu 1 --memory 1.5 `
  --os-type Linux `
  --ports 8080 `
  --dns-name-label mottuapi-<ID> `
  --environment-variables `
     SPRING_PROFILES_ACTIVE=production `
     SPRING_DATASOURCE_URL="jdbc:mysql://<IP>:3306/mottu?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC" `
     SPRING_DATASOURCE_USERNAME="mottuadmin" `
     SPRING_DATASOURCE_PASSWORD="QualiTracker123!" `
     SPRING_FLYWAY_URL="jdbc:mysql://<IP>:3306/mottu?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC" `
     SPRING_FLYWAY_USER="mottuadmin" `
     SPRING_FLYWAY_PASSWORD="QualiTracker123!" `
  --registry-login-server mottuacr01.azurecr.io `
  --registry-username <USER_DO_ACR> `
  --registry-password "<SENHA_DO_ACR>" `
  --ip-address Public
```

Verifique o FQDN:

```powershell
az container show -g mottu-rg -n mottu-api --query "ipAddress.fqdn" -o tsv
```

Exemplo retornado: `mottuapi-<ID>.brazilsouth.azurecontainer.io`

### ✅ 7. Testar a API

Abra no navegador:

```
http://mottuapi-<ID>.brazilsouth.azurecontainer.io:8080
```

## 🔗 Acesso Externo aos Serviços

### 🗄️ **Acessar MySQL via MySQL Workbench**

1. **Obtenha o IP público do MySQL:**
```powershell
az container show -g mottu-rg -n mottu-mysql --query "ipAddress.ip" -o tsv
```

2. **Configure a conexão no MySQL Workbench:**
   - **Hostname**: `<IP_PUBLICO_MYSQL>` (ex: 20.123.45.67)
   - **Port**: `3306`
   - **Username**: `root`
   - **Password**: `QualiTracker123!`
   - **Default Schema**: `mottu`

3. **Teste a conexão** e explore o banco de dados.

### 🌐 **Testar API via Postman**

1. **Obtenha o FQDN da API:**
```powershell
az container show -g mottu-rg -n mottu-api --query "ipAddress.fqdn" -o tsv
```

2. **Configure o Postman:**
   - **Base URL**: `http://mottuapi-<ID>.brazilsouth.azurecontainer.io:8080`
   - **Headers**: `Content-Type: application/json`

3. **Coleções de Teste:**

#### 📱 **Teste Sensores UWB**

**Criar Sensor:**
```
POST http://mottuapi-<ID>.brazilsouth.azurecontainer.io:8080/api/sensores
Content-Type: application/json

{
  "localizacao": "Pátio Centro - Zona A"
}
```

**Listar Sensores:**
```
GET http://mottuapi-<ID>.brazilsouth.azurecontainer.io:8080/api/sensores
```

#### 🏍️ **Teste Motos**

**Criar Moto:**
```
POST http://mottuapi-<ID>.brazilsouth.azurecontainer.io:8080/api/motos
Content-Type: application/json

{
  "modelo": "Honda CG 160",
  "cor": "Vermelha",
  "identificadorUWB": "UWB001",
  "sensorId": 1,
  "status": "DISPONIVEL"
}
```

**Listar Motos:**
```
GET http://mottuapi-<ID>.brazilsouth.azurecontainer.io:8080/api/motos
```

#### 📋 **Teste Alocações**

**Abrir Alocação:**
```
POST http://mottuapi-<ID>.brazilsouth.azurecontainer.io:8080/api/alocacoes/abrir
Content-Type: application/json

{
  "motoId": 1
}
```

**Listar Alocações:**
```
GET http://mottuapi-<ID>.brazilsouth.azurecontainer.io:8080/api/alocacoes
```

#### 🔧 **Teste Manutenções**

**Abrir Manutenção:**
```
POST http://mottuapi-<ID>.brazilsouth.azurecontainer.io:8080/api/manutencoes
Content-Type: application/json

{
  "motoId": 1,
  "descricao": "Troca de óleo e filtro"
}
```

**Listar Manutenções:**
```
GET http://mottuapi-<ID>.brazilsouth.azurecontainer.io:8080/api/manutencoes
```

### 🔍 **Verificar Logs dos Containers**

**Logs da API:**
```powershell
az container logs --resource-group mottu-rg --name mottu-api
```

**Logs do MySQL:**
```powershell
az container logs --resource-group mottu-rg --name mottu-mysql
```

### 🛠️ **Troubleshooting**

**Verificar Status dos Containers:**
```powershell
az container list --resource-group mottu-rg --output table
```

**Reiniciar Container da API:**
```powershell
az container restart --resource-group mottu-rg --name mottu-api
```

**Verificar Variáveis de Ambiente:**
```powershell
az container show --resource-group mottu-rg --name mottu-api --query "containers[0].environmentVariables"
```

## 📚 Documentação da API

### 📱 **Sensores UWB** (`/api/sensores`)

**Criar (POST)**
```json
{
  "localizacao": "Pátio Centro - Zona A"
}
```

**Atualizar (PUT)**
```json
{
  "id": 1,
  "localizacao": "Pátio Centro - Zona A Reformada"
}
```

**Listar (GET)**
```
GET /api/sensores
GET /api/sensores/{id}
```

**Deletar (DELETE)**
```
DELETE /api/sensores/{id}
```

### 🏍️ **Motos** (`/api/motos`)

**Criar (POST)**
```json
{
  "modelo": "Honda CG 160",
  "cor": "Vermelha",
  "identificadorUWB": "UWB001",
  "sensorId": 1,
  "status": "DISPONIVEL"
}
```

**Atualizar (PUT)**
```json
{
  "id": 1,
  "modelo": "Honda CG 160 Titan",
  "cor": "Azul",
  "identificadorUWB": "UWB001",
  "sensorId": 1,
  "status": "DISPONIVEL"
}
```

**Listar (GET)**
```
GET /api/motos
GET /api/motos/{id}
GET /api/motos/buscar/uwb?identificadorUWB=UWB001
```

**Deletar (DELETE)**
```
DELETE /api/motos/{id}
```

### 📋 **Alocações** (`/api/alocacoes`)

**Abrir Alocação (POST)**
```json
{
  "motoId": 1
}
```

**Encerrar Alocação (POST)**
```
POST /api/alocacoes/encerrar/1
```

**Listar (GET)**
```
GET /api/alocacoes
GET /api/alocacoes/abertas
```

### 🔧 **Manutenções** (`/api/manutencoes`)

**Abrir Manutenção (POST)**
```json
{
  "motoId": 1,
  "descricao": "Troca de óleo e filtro"
}
```

**Encerrar Manutenção (PUT)**
```
PUT /api/manutencoes/1/encerrar
```

**Listar (GET)**
```
GET /api/manutencoes
GET /api/manutencoes/abertas
```

## 🛠️ Tecnologias Utilizadas

- **Java 17**
- **Spring Boot 3.4.5**
- **Spring Data JPA**
- **Spring Security**
- **Thymeleaf**
- **MySQL 8.0**
- **Flyway** (Migrações de banco)
- **Lombok**
- **Docker**

## 🏗️ Estrutura do Projeto

```
src/
├── main/
│   ├── java/com/mottu/rastreamento/
│   │   ├── controller/
│   │   │   ├── api/          # Controllers REST
│   │   │   └── view/         # Controllers Thymeleaf
│   │   ├── dto/              # Data Transfer Objects
│   │   ├── models/           # Entidades JPA
│   │   ├── repository/       # Repositórios JPA
│   │   ├── service/          # Lógica de negócio
│   │   └── security/         # Configurações de segurança
│   └── resources/
│       ├── application.yml   # Configurações
│       ├── db/migration/     # Scripts Flyway
│       └── templates/        # Templates Thymeleaf
└── test/                     # Testes unitários
```

## 🔧 Desenvolvimento Local

### Pré-requisitos
- Java 17+
- Maven 3.6+
- MySQL 8.0+

### Executar localmente

1. Clone o repositório
2. Configure o MySQL local
3. Atualize as configurações no `application.yml`
4. Execute:
```bash
mvn spring-boot:run
```

A aplicação estará disponível em: `http://localhost:8080`

## 📝 Status das Entidades

### Status da Moto
- `DISPONIVEL` - Moto disponível para alocação
- `ALOCADA` - Moto em uso
- `MANUTENCAO` - Moto em manutenção
- `INDISPONIVEL` - Moto indisponível

### Status da Alocação
- `ABERTA` - Alocação ativa
- `FECHADA` - Alocação encerrada

### Status da Manutenção
- `ABERTA` - Manutenção em andamento
- `FECHADA` - Manutenção concluída
