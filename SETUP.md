# 🚀 Setup Azure - QualiTracker

## Executar Script

```bash
chmod +x setup-azure-resources.sh
./setup-azure-resources.sh
```

## Recursos Criados

- Resource Group: `qualitracker-mottu-rg`
- MySQL: `qualitracker-mysql-server`
- Database: `qualitracker`
- Usuário: `qualitracker_user`
- Web App: `qualitracker-app` (Java 17)

## Acesso

**App**: `https://qualitracker-app.azurewebsites.net`

**MySQL Workbench**:
- Host: `qualitracker-mysql-server.mysql.database.azure.com`
- Port: `3306`
- User: `qualitracker_user`
- SSL: REQUIRED

