#Buildar projeto maven 
FROM maven:3.9.4-eclipse-temurin AS build
WORKDIR /app

#Copiar arquivos para o container
COPY . .

#Compila o projeto e gera o JAR
RUN mvn clean package -Dskiptests

#Selecionado imagem mais leve para rodar o projeto java
FROM eclipse-temurin:17-jdk-jammy
WORKDIR /app

#Copiar o JAR gerado no build anterior
COPY --from=build /app/target/*.jar app.jar

#Expor porta para comunicação
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]

