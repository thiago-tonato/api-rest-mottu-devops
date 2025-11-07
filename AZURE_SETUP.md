# 📋 Setup Azure DevOps - Sprint 4

## 1. Criar Projeto Azure DevOps

- **Nome**: `Sprint 4 – Azure DevOps`
- **Visibility**: Private
- **Version control**: Git

## 2. Criar Variable Group

**Pipelines → Library → Variable groups**

Nome: `mottu-variables`

| Variável | Tipo | Exemplo |
|----------|------|---------|
| `azureSubscription` | Normal | `nome-service-connection` |
| `resourceGroup` | Normal | `qualitracker-mottu-rg` |
| `location` | Normal | `brazilsouth` |
| `containerGroupName` | Normal | `qualitracker-aci` |
| `dnsLabel` | Normal | `qualitracker-dev` (precisa ser único na região) |
| `acrName` | Normal | `qualitrackeracr` |
| `appImageName` | Normal | `qualitracker-app` |
| `mysqlImageName` | Normal | `qualitracker-mysql` |
| `mysqlImageTag` | Normal | `8.0` |
| `mysqlDatabase` | Normal | `qualitracker` |
| `mysqlUser` | Secret | `qualitracker_user` |
| `mysqlPassword` | Secret | `senha-app` |
| `mysqlRootPassword` | Secret | `senha-root` |
| `appContainerName` | (opcional) Normal | `qualitracker-app` |
| `mysqlContainerName` | (opcional) Normal | `qualitracker-mysql` |

**⚠️ Marque as senhas como Secret.**

## 3. Service Connection

**Azure Resource Manager**
- Nome: usar em `azureSubscription`

## 4. Pipeline

1. **Pipelines → New Pipeline**
2. Selecionar repositório GitHub
3. Escolher `azure-pipelines.yml`
4. Salvar e executar (o pipeline expõe a aplicação em 8080 e o MySQL em 3306).

## 5. Preparar Recursos Azure

Execute o script (apenas uma vez ou quando precisar recriar a infraestrutura base):
```bash
./setup-azure-resources.sh
```
Ele garante a existência do Resource Group e do Azure Container Registry (com a imagem base do MySQL).

O deploy completo (build da imagem da aplicação e criação/atualização do container group) é feito pelo pipeline. Após a execução, você terá:
- App: `http://<dnsLabel>.brazilsouth.azurecontainer.io:8080`
- MySQL: `<dnsLabel>.brazilsouth.azurecontainer.io:3306`

## 6. Convidar Professor

**Project Settings → Users → Invite**
- Email do professor
- Access level: Basic
