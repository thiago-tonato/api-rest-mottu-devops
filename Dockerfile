#Buildar projeto maven 
FROM maven:3.9.4-eclipse-temurin AS build
WORKDIR /app

#Copiar arquivos de configuração do Maven
COPY pom.xml .

#Copiar o código fonte
COPY src src

#Compila o projeto e gera o JAR
RUN mvn clean package -DskipTests

# Runtime stage - Imagem otimizada para produção
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app

# Criar usuário não-root para segurança
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Copiar o JAR gerado no build anterior
COPY --from=build /app/target/*.jar app.jar

# Definir propriedades do usuário (NÃO RODA COMO ROOT)
RUN chown -R appuser:appuser /app
USER appuser

# Expor porta para comunicação
EXPOSE 8080

# Configurações JVM otimizadas para containers
ENTRYPOINT ["java", \
  "-XX:+UseContainerSupport", \
  "-XX:MaxRAMPercentage=75.0", \
  "-XX:+UseG1GC", \
  "-Djava.security.egd=file:/dev/./urandom", \
  "-Dspring.profiles.active=production", \
  "-jar", "app.jar"]

