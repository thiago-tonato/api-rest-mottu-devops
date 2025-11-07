# 🚀 Setup Azure - QualiTracker

## Executar Script (Infra base)

```bash
chmod +x setup-azure-resources.sh
./setup-azure-resources.sh
```

O script garante:
- Resource Group `qualitracker-mottu-rg`
- Azure Container Registry `qualitrackeracr.azurecr.io`
- Imagem base MySQL (`qualitracker-mysql:8.0`) armazenada no ACR

## Variáveis necessárias no Azure DevOps

Crie/atualize o Variable Group `mottu-variables` com:

- `azureSubscription` (nome da service connection)
- `resourceGroup` (`qualitracker-mottu-rg`)
- `location` (`brazilsouth`)
- `containerGroupName` (`qualitracker-aci`)
- `dnsLabel` (ex.: `qualitracker-dev`)
- `acrName` (`qualitrackeracr`)
- `appImageName` (`qualitracker-app`)
- `mysqlImageName` (`qualitracker-mysql`)
- `mysqlImageTag` (`8.0`)
- `mysqlDatabase` (`qualitracker`)
- `mysqlUser` *(Secret)*
- `mysqlPassword` *(Secret)*
- `mysqlRootPassword` *(Secret)*
- (opcionais) `appContainerName`, `mysqlContainerName`

## Deploy

O pipeline `azure-pipelines.yml`:
1. Builda e publica a imagem da aplicação no ACR (tags `BuildId` e `latest`).
2. Cria/atualiza o container group no Azure Container Instances com dois contêineres (app + MySQL) usando as variáveis acima. A porta 8080 expõe a aplicação web e a porta 3306 expõe o MySQL externamente (use apenas para fins acadêmicos/teste).

Após o deploy, a aplicação ficará disponível em:
```
http://<dnsLabel>.brazilsouth.azurecontainer.io:8080
```

O MySQL ficará acessível em:
```
<dnsLabel>.brazilsouth.azurecontainer.io:3306
```
Use as credenciais configuradas (`mysqlUser` / `mysqlPassword`).

### Acesso ao MySQL via Workbench (pós-deploy)

- Host: `<dnsLabel>.brazilsouth.azurecontainer.io`
- Porta: `3306`
- Usuário: valor da variável `mysqlUser`
- Senha: valor da variável `mysqlPassword`
- Banco: valor da variável `mysqlDatabase` (padrão `qualitracker`)
- Observações:
  - Garanta que o container group está em execução e expondo a porta `3306`.
  - Use conexões apenas para fins acadêmicos/testes; considere túnel seguro/VPN para ambientes produtivos.

Para consultar logs:
```bash
az container logs --resource-group <resourceGroup> --name <containerGroupName> --container <appContainerName>
```

