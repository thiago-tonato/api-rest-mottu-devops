# 🚀 Quick Reference

## Checklist

- [ ] Projeto Azure DevOps criado
- [ ] Variable Group configurado (contêineres)
- [ ] Service Connections criadas
- [ ] Pipeline executado com sucesso
- [ ] Recursos Azure criados (`setup-azure-resources.sh`)

## Variáveis Azure DevOps

**Group**: `mottu-variables`

| Variável | Tipo |
|----------|------|
| `azureSubscription` | Normal |
| `containerGroupName` | Normal |
| `acrName` | Normal |
| `appImageName` | Normal |

## Troubleshooting

**Pipeline falha**: Verificar permissions do Service Connection e se o ACR já existe

**Container não sobe**: Ver logs com `az container logs --resource-group <rg> --name <container-group>`

**App não encontra o banco**: Confirme se ambos contêineres estão rodando no mesmo container group e revise as senhas expostas no final do script
