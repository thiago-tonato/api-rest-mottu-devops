# 🏍️ QualiTracker - Rastreamento de Motos Mottu

Aplicação Spring Boot para rastreamento e gestão de motos com sensores UWB.

## ⚙️ Stack

- Java 17, Spring Boot 3.4.5
- MySQL, Flyway
- Docker, Azure Container Registry, Azure Container Instances, Azure DevOps CI/CD

## 🚀 Setup Rápido

### Local
```bash
./mvnw spring-boot:run
```
Acesse: `http://localhost:8080` (admin/admin123)

### Azure (contêineres)
```bash
chmod +x setup-azure-resources.sh
./setup-azure-resources.sh
```
O script apenas prepara o Resource Group e o Azure Container Registry. O deploy completo (build da imagem + criação/atualização do container group) é realizado pelo pipeline `azure-pipelines.yml`. Após o pipeline, a aplicação fica exposta em `http://<dnsLabel>.brazilsouth.azurecontainer.io:8080` e o MySQL em `<dnsLabel>.brazilsouth.azurecontainer.io:3306` (use as credenciais definidas nas variáveis `mysqlUser`/`mysqlPassword`).

## 📋 Funcionalidades

- CRUD de Motos e Sensores UWB
- Alocação e Manutenção de Motos
- Spring Security (ADMIN/USER)
- Thymeleaf Frontend

## 🔄 Endpoints API

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| GET | `/api/motos` | Lista motos |
| POST | `/api/motos` | Cria moto |
| GET | `/api/sensores` | Lista sensores |
| POST | `/api/sensores` | Cria sensor |

## 👥 Equipe

- Murilo Ribeiro Santos (RM555109)
- Thiago Garcia Tonato (RM99404)
- Ian Madeira Gonçalves da Silva (RM555502)

**FIAP - Análise e Desenvolvimento de Sistemas**
