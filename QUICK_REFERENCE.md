# 🚀 Quick Reference

## Checklist

- [ ] Projeto Azure DevOps criado
- [ ] Variable Group configurado (contêineres)
- [ ] Service Connections criadas
- [ ] Recursos Azure preparados (`setup-azure-resources.sh`)
- [ ] Pipeline executado com sucesso

## Variáveis Azure DevOps

**Group**: `mottu-variables`

| Variável | Tipo |
|----------|------|
| `azureSubscription` | Normal |
| `resourceGroup` | Normal |
| `location` | Normal |
| `containerGroupName` | Normal |
| `dnsLabel` | Normal |
| `acrName` | Normal |
| `appImageName` | Normal |
| `mysqlImageName` | Normal |
| `mysqlImageTag` | Normal |
| `mysqlDatabase` | Normal |
| `mysqlUser` | Secret |
| `mysqlPassword` | Secret |
| `mysqlRootPassword` | Secret |
| `appContainerName` | (opcional) Normal |
| `mysqlContainerName` | (opcional) Normal |

## Troubleshooting

**Pipeline falha no push**: Verifique se o ACR `qualitrackeracr` foi criado (execute novamente o script e aguarde propagação DNS).

**Container não sobe**: Consulte os logs com `az container logs --resource-group <rg> --name <container-group> --container <appContainerName>`.

**App não encontra o banco**: Confirme as variáveis `mysqlUser/mysqlPassword/mysqlDatabase` e se os contêineres usam o mesmo container group.
