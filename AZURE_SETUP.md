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
| `azureSubscription` | `nome-service-connection` |
| `containerGroupName` | `qualitracker-aci` |
| `acrName` | `qualitrackeracr` |
| `appImageName` | `qualitracker-app:latest` |

**⚠️ Mantenha credenciais sensíveis como Secret**

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

Recursos provisionados automaticamente:
- Resource Group
- Azure Container Registry (imagens da aplicação e do banco)
- Azure Container Instances (container group com app + MySQL)

## 6. Convidar Professor

**Project Settings → Users → Invite**
- Email do professor
- Access level: Basic
