#Buildar projeto maven 
FROM maven:3.9.4-eclipse-temurin AS build
WORKDIR /app

#Copiar arquivos de configuração do Maven
COPY pom.xml .

#Baixar dependências (para cache do Docker)
RUN mvn dependency:go-offline -B

#Copiar o código fonte
COPY src src

#Compila o projeto e gera o JAR
RUN mvn clean package -DskipTests

#Selecionado imagem mais leve para rodar o projeto java
FROM eclipse-temurin:17-jdk-jammy
WORKDIR /app

#Copiar o JAR gerado no build anterior
COPY --from=build /app/target/*.jar app.jar

#Expor porta para comunicação
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]

