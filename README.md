# 🏍️ QualiTracker - Rastreamento de Motos Mottu

Aplicação Spring Boot para rastreamento e gestão de motos com sensores UWB.

## ⚙️ Stack

- Java 17, Spring Boot 3.4.5
- MySQL, Flyway
- Azure DevOps CI/CD, Azure Web App

## 🚀 Setup Rápido

### Local
```bash
./mvnw spring-boot:run
```
Acesse: `http://localhost:8080` (admin/admin123)

### Azure
```bash
chmod +x setup-azure-resources.sh
./setup-azure-resources.sh
```

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
