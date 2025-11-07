#!/bin/sh

set -eu

DB_HOST="${DB_HOST:-127.0.0.1}"
DB_PORT="${DB_PORT:-3306}"

echo "[entrypoint] Esperando MySQL em ${DB_HOST}:${DB_PORT}..."
until nc -z "$DB_HOST" "$DB_PORT"; do
  sleep 2
done

# Delay extra para o MySQL concluir inicialização
sleep 5

echo "[entrypoint] Banco disponível, iniciando aplicação Spring Boot."
exec java ${JAVA_OPTS:-} -Djava.security.egd=file:/dev/./urandom -jar /app/app.jar

