#!/bin/bash
set -euo pipefail

echo "=== airflow_init: esperando a Postgres ==="
retries=0
max_retries=60
until pg_isready -h postgres_db -U airflow -d airflow || [ $retries -ge $max_retries ]; do
  retries=$((retries+1))
  echo "Intento $retries/$max_retries: esperando 2s..."
  sleep 2
done

if [ $retries -ge $max_retries ]; then
  echo "ERROR: Postgres no respondió en el tiempo esperado" >&2
  exit 1
fi

echo "Postgres listo. Ejecutando inicialización de Airflow..."
mkdir -p /opt/airflow/logs

# inicializar DB y aplicar migraciones (idempotente)
airflow db init 2>&1 | tee /opt/airflow/logs/airflow_db_init.log || true
airflow db upgrade 2>&1 | tee -a /opt/airflow/logs/airflow_db_init.log || true

# crear usuario admin (ignorar si ya existe)
airflow users create \
  --username admin \
  --firstname Admin \
  --lastname User \
  --role Admin \
  --email admin@example.com \
  --password admin 2>&1 | tee -a /opt/airflow/logs/airflow_db_init.log || true

echo "Airflow init completed successfully"
exit 0
