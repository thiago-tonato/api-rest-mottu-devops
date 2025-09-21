# 🏍️ Rastreamento de Motos com UWB — API Java Spring Boot

Aplicação Web completa desenvolvida em Spring Boot, com foco em Thymeleaf (frontend), Flyway (versionamento do banco) e Spring Security (autenticação e autorização).
A solução oferece suporte ao rastreamento preciso de motos da Mottu, integrando controle de alocações e manutenções, além do cadastro de motos e sensores UWB.

---

## 📌 Objetivo

Resolver o problema de localização e gestão de motos em pátios de alta densidade, utilizando sensores UWB (Ultra Wideband) para rastreamento individual, aliado a uma aplicação segura e fácil de usar.

---

## ⚙️ Tecnologias Utilizadas

✅ Java 17

✅ Spring Boot 3.4.5

✅ Spring Web

✅ Spring Data JPA

✅ Spring Security (BCrypt, roles ADMIN/USER)

✅ Thymeleaf + Thymeleaf Extras Spring Security

✅ Bean Validation

✅ Flyway (versionamento do banco)

✅ PostgreSQL

✅ Maven

---

## 🗂️ Funcionalidades da Aplicação
### 🔧 CRUDs com Thymeleaf

- Motos
- Sensores UWB:
  - ✔️ Com validação de campos e mensagens de erro no formulário
  - ✔️ Páginas estruturadas com fragments (_head, _navbar, _footer)

### 🔐 Segurança

- Login via formulário (Spring Security + Thymeleaf)
- Usuários com perfis ADMIN e USER
- Regras de acesso:
  - /motos, /sensores, /alocacoes, /manutencoes → ADMIN e USER
  - Apenas ADMIN pode criar, editar ou excluir

### 📦 Versionamento do Banco (Flyway)

- V1__create_sensores.sql → Criação da tabela de sensores
- V2__create_motos.sql → Criação da tabela de motos
- V3__insert_sensores.sql → Seed de sensores iniciais
- V4__insert_motos.sql → Seed de motos iniciais
- V5__create_roles.sql → Criação de roles
- V6__create_users.sql → Criação de usuários
- V7__create_alocacoes.sql → Criação de alocações
- V8__create_manutencoes.sql → Criação de manutenções
- V9__insert_roles_and_users.sql → Seed de roles e usuários (admin123, user123)

### 🔄 Funcionalidades Avançadas

#### Fluxo A — Alocação de Motos
- Abrir alocação → moto precisa estar DISPONÍVEL
- Encerrar alocação → moto volta a ficar DISPONÍVEL
- Impede múltiplas alocações abertas para a mesma moto
- Listagem de alocações abertas + histórico

#### Fluxo B — Manutenção
- Abrir manutenção → moto muda para MANUTENÇÃO
- Fechar manutenção → moto volta para DISPONÍVEL
- Impede alocação de moto em manutenção
- Lista de manutenções abertas e encerradas

### ✅ Extras

- Formatação de datas para dd/MM/yyyy HH:mm
- Páginas adaptadas conforme perfil:
  - Usuário USER → sem botões de “Nova” e sem coluna de ações
  - Usuário ADMIN → pode gerenciar todas as entidades

---

## 🔄 Endpoints da API (REST)
### 📌 Motos

| Método | Endpoint                          | Descrição                                |
|--------|-----------------------------------|------------------------------------------|
GET	| api/motos	| Lista motos |
GET	| api/motos/{id} |	Busca moto por ID |
POST	| api/motos	| Cria nova moto |
PUT	| api/motos/{id} | Atualiza moto existente |
DELETE	| api/motos/{id} |	Remove moto |

### 📌 Sensores

| Método | Endpoint                          | Descrição                                |
|--------|-----------------------------------|------------------------------------------|
GET	| api/sensores |	Lista sensores |
GET	| api/sensores/{id}	| Busca sensor por ID |
POST	| api/sensores | Cria novo sensor |
PUT	| api/sensores/{id}	| Atualiza sensor existente |
DELETE	| api/sensores/{id}	| Remove sensor |

### 📌 Alocações

| Método | Endpoint                          | Descrição                                |
|--------|-----------------------------------|------------------------------------------|
GET	 | api/alocacoes  |	Lista alocações  |
POST	 |api/alocacoes  |	Abre alocação  |
PUT	 | api/alocacoes/{id}  |	Encerra alocação  |
### 📌 Manutenções

| Método | Endpoint                          | Descrição                                |
|--------|-----------------------------------|------------------------------------------|
GET	 | api/manutencoes	 | Lista manutenções  |
POST	 | api/manutencoes  |	Abre manutenção  |
PUT	 | api/manutencoes/{id}  | Encerra manutenção  |

---

## 🧪 Como rodar localmente
### Clone o repositório:
```
git clone https://github.com/murilors27/api-rest-mottu.git
cd api-rest-mottu
```

### Configure o banco PostgreSQL no application.yml:
```java
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/mottu
    username: postgres
    password: postgres
  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: true
  flyway:
    enabled: true
```

### Execute o projeto:
```
./mvnw spring-boot:run
```

### Acesse:
- Frontend (Thymeleaf): http://localhost:8080/motos
- Login:
  - Admin → admin / admin123
  - User → user / user123

---

## 📸 Exemplos de JSON (API)
Criar Moto
```
{
  "modelo": "Honda CG 160",
  "cor": "Preto",
  "identificadorUWB": "UWB001",
  "sensorId": 1
}
```

Criar Sensor
```
{
  "localizacao": "Setor A - Coluna 3"
}
```

---

## 👥 Equipe

| Nome                                | RM       | GitHub                                |
|-------------------------------------|----------|----------------------------------------|
| Murilo Ribeiro Santos               | RM555109 | [@murilors27](https://github.com/murilors27) |
| Thiago Garcia Tonato                | RM99404  | [@thiago-tonato](https://github.com/thiago-tonato) |
| Ian Madeira Gonçalves da Silva      | RM555502 | [@IanMadeira](https://github.com/IanMadeira) |

**Curso**: Análise e Desenvolvimento de Sistemas  
**Instituição**: FIAP – Faculdade de Informática e Administração Paulista
