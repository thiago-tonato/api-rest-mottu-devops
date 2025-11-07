# 🚀 Setup Azure - QualiTracker

## Executar Script

```bash
chmod +x setup-azure-resources.sh
./setup-azure-resources.sh
```

O script:
- Cria o Resource Group
- Provisiona o Azure Container Registry
- Builda e publica as imagens da aplicação e do MySQL
- Cria um container group no Azure Container Instances com os dois contêineres

## Recursos Criados

- Resource Group: `qualitracker-mottu-rg`
- Azure Container Registry: `qualitrackeracr.azurecr.io`
- Container Group: `qualitracker-aci`
- Contêineres: `qualitracker-app` (Spring Boot) + `qualitracker-mysql` (MySQL 8)

## Acesso

- **Aplicação**: `http://qualitracker-XXXXX.brazilsouth.azurecontainer.io:8080`
  - O sufixo `XXXXX` (DNS) é exibido ao final do script
- **Banco de dados**: Apenas acessível dentro do container group
  - Use `az container exec --container qualitracker-mysql` para abrir o cliente MySQL

## Credenciais Geradas

- Usuário do banco: `qualitracker_user`
- Senha do banco: exibida no resumo do script
- Senha root MySQL: exibida no resumo do script

⚠️ Salve as senhas imediatamente — elas não ficam armazenadas em lugar algum após o término do script.

