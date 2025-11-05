# 📄 Entrega Sprint 4

## 1. Informações da Equipe

| Nome | RM | Turma |
|------|-----|-------|
| Murilo Ribeiro Santos | RM555109 | [Turma] |
| Thiago Garcia Tonato | RM99404 | [Turma] |
| Ian Madeira Gonçalves da Silva | RM555502 | [Turma] |

## 2. Links

- **GitHub**: [URL]
- **YouTube**: [URL]
- **Azure DevOps**: [URL]

## 3. Descrição da Solução (5 pontos)

Aplicação Spring Boot para rastreamento de motos com UWB. Stack: Java 17, Spring Boot 3.4.5, MySQL, Docker, Azure DevOps CI/CD, Azure Web App.

## 4. Diagrama Arquitetura (10 pontos)

```
Desenvolvedor → GitHub → Azure DevOps CI → Docker Build → Azure DevOps CD → Web App → MySQL
```

**Fluxo:**
1. Push → GitHub
2. CI executa build/testes
3. Docker build/push
4. CD faz deploy
5. App disponível

## 5. Detalhamento Componentes (10 pontos)

| Componente | Tipo | Tecnologia |
|-----------|------|------------|
| Repositório | SCM | GitHub |
| Pipeline CI | CI | Azure DevOps |
| Pipeline CD | CD | Azure DevOps |
| Banco | PaaS | Azure MySQL |
| Runtime | Container | Azure Web App |

## 6. Banco de Dados

**Tipo**: Azure Database for MySQL (PaaS)

**String de Conexão**: Configurada via variáveis de ambiente protegidas.

## 7. Configuração Azure DevOps

- **Nome**: Sprint 4 – Azure DevOps
- **Description**: Projeto para entrega da Sprint 4 do professor Karlos Miguel
- **Visibility**: Private
- **Version control**: Git

## 8. Pipelines CI/CD

**CI**: Build, testes, artefatos  
**CD**: Deploy automático para Azure Web App  
**Docker**: Imagem containerizada obrigatória

## 9. Vídeo Demonstrativo (45 pontos)

- Ferramentas abertas (IDE, Azure DevOps, Portal)
- Pipeline executando
- CRUD completo funcionando
- Acesso externo (HTTP e MySQL Workbench)
