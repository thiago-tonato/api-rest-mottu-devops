# 🚀 Quick Reference

## Checklist

- [ ] Projeto Azure DevOps criado
- [ ] Variable Group configurado
- [ ] Service Connections criadas
- [ ] Pipeline executado com sucesso
- [ ] Recursos Azure criados (`setup-azure-resources.sh`)

## Variáveis Azure DevOps

**Group**: `mottu-variables`

| Variável | Tipo |
|----------|------|
| `DATASOURCE_URL` | Secret |
| `DATASOURCE_USERNAME` | Secret |
| `DATASOURCE_PASSWORD` | Secret |
| `FLYWAY_URL` | Secret |
| `FLYWAY_USER` | Secret |
| `FLYWAY_PASSWORD` | Secret |
| `azureSubscription` | Normal |
| `webAppName` | Normal |

## Comandos Úteis

```bash
# Build local
./mvnw clean package

# Docker
docker build -t qualitracker-rastreamento:latest .
docker run -p 8080:8080 qualitracker-rastreamento:latest

# Azure
az login
az group list
```

## Troubleshooting

**Pipeline falha**: Verificar logs, service connections, variáveis

**App não conecta ao banco**: Verificar variáveis de ambiente no Web App, firewall MySQL

**MySQL não conecta**: Verificar firewall, SSL requerido, credenciais
