# 🏍️ Rastreamento de Motos com UWB — API Java Spring Boot

API REST desenvolvida para oferecer suporte à solução de rastreamento preciso de motos utilizando sensores UWB (Ultra Wideband), voltada para ambientes de alta densidade, como pátios da Mottu.

---

## 📌 Objetivo

Resolver o problema de localização imprecisa em pátios onde motos ficam muito próximas umas das outras, utilizando sensores UWB que permitem rastreamento e identificação individual e em tempo real.

---

## ⚙️ Tecnologias Utilizadas

- ✅ Java 17
- ✅ Spring Boot 3.4.5
- ✅ Spring Web
- ✅ Spring Data JPA
- ✅ Banco de Dados H2 (em memória)
- ✅ Bean Validation
- ✅ Cache com `@Cacheable`
- ✅ Maven
- ✅ Docker-ready

---

## 🗂️ Funcionalidades da API

- 🔄 CRUD completo de motos e sensores UWB
- 🔗 Relacionamento entre motos e sensores
- 🔍 Busca por identificador UWB
- 📄 Paginação e ordenação de resultados
- ✅ Validação de campos (ex: modelo, cor, sensor)
- 🚫 Tratamento centralizado de erros (HTTP 400, 404, 500)
- ⚡ Cache para otimizar buscas repetidas
- 🌐 Pronta para containerização e deploy em nuvem

---

## 🔄 Endpoints principais

### 📌 Motos

| Método | Endpoint                          | Descrição                                |
|--------|-----------------------------------|------------------------------------------|
| GET    | `/api/motos`                      | Lista motos com paginação                |
| GET    | `/api/motos/{id}`                 | Busca moto por ID                        |
| GET    | `/api/motos/buscar/uwb`           | Busca por identificadorUWB               |
| POST   | `/api/motos`                      | Cadastra nova moto                       |
| PUT    | `/api/motos/{id}`                 | Atualiza uma moto existente              |
| DELETE | `/api/motos/{id}`                 | Remove uma moto                          |

### 📌 Sensores UWB

| Método | Endpoint              | Descrição                     |
|--------|-----------------------|-------------------------------|
| GET    | `/api/sensores`       | Lista todos os sensores       |
| GET    | `/api/sensores/{id}`  | Busca sensor por ID           |
| POST   | `/api/sensores`       | Cadastra novo sensor          |
| PUT    | `/api/sensores/{id}`  | Atualiza um sensor existente  |
| DELETE | `/api/sensores/{id}`  | Remove um sensor              |

---

## 🧪 Como rodar localmente

### Clone o repositório:

git clone https://github.com/seu-usuario/rastreamento-uwb-java.git  
cd rastreamento-uwb-java

### Execute o projeto:

./mvnw spring-boot:run

### Acesse a API:

http://localhost:8080/api/motos

---

## 🐳 Docker (para DevOps)

> O projeto está pronto para rodar em containers.

### application.properties:

server.port=8080  
server.address=0.0.0.0

### Exemplo de Dockerfile:

FROM eclipse-temurin:17  
WORKDIR /app  
COPY target/rastreamento-0.0.1-SNAPSHOT.jar app.jar  
EXPOSE 8080  
ENTRYPOINT ["java", "-jar", "app.jar"]

---

## 📸 Exemplos de JSON

### Criar Moto:

{  
&nbsp;&nbsp;"modelo": "Honda CG 160",  
&nbsp;&nbsp;"cor": "Preto",  
&nbsp;&nbsp;"identificadorUWB": "UWB001",  
&nbsp;&nbsp;"sensorId": 1  
}

### Criar Sensor:

{  
&nbsp;&nbsp;"localizacao": "Setor A - Coluna 3"  
}

---

## 👥 Equipe

- **Murilo Ribeiro** — RM555109  
- **Thiago Garcia** — RM99404  
- **Ian Madeira** — RM555502
