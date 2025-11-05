# 📋 Setup Azure DevOps - Sprint 4

## 1. Criar Projeto Azure DevOps

- **Nome**: `Sprint 4 – Azure DevOps`
- **Visibility**: Private
- **Version control**: Git

## 2. Criar Variable Group

**Pipelines → Library → Variable groups**

Nome: `mottu-variables`

| Variável | Valor |
|----------|-------|
| `DATASOURCE_URL` | `jdbc:mysql://servidor.mysql.database.azure.com:3306/qualitracker` |
| `DATASOURCE_USERNAME` | `qualitracker_user` |
| `DATASOURCE_PASSWORD` | `[senha]` |
| `FLYWAY_URL` | `jdbc:mysql://servidor.mysql.database.azure.com:3306/qualitracker` |
| `FLYWAY_USER` | `qualitracker_user` |
| `FLYWAY_PASSWORD` | `[senha]` |
| `azureSubscription` | `nome-service-connection` |
| `webAppName` | `qualitracker-app` |

**⚠️ Marcar senhas como Secret**

## 3. Service Connection

**Azure Resource Manager**
- Nome: usar em `azureSubscription`

## 4. Pipeline

1. **Pipelines → New Pipeline**
2. Selecionar repositório GitHub
3. Escolher `azure-pipelines.yml`
4. Salvar e executar

## 5. Criar Recursos Azure

Execute o script:
```bash
./setup-azure-resources.sh
```

Ou manualmente:
- Azure Database for MySQL Flexible Server
- Azure Web App (Java 17)

## 6. Convidar Professor

**Project Settings → Users → Invite**
- Email do professor
- Access level: Basic
