#!/bin/bash

# Salir inmediatamente si un comando falla
set -e

echo "--- Iniciando Servicios de Data Science ---"

# 1. Iniciar Spark Master en segundo plano
echo "Iniciando Spark Master..."
${SPARK_HOME}/sbin/start-master.sh --host 0.0.0.0

# 2. Iniciar Spark Worker y conectarlo al Master local
echo "Iniciando Spark Worker..."
${SPARK_HOME}/sbin/start-worker.sh spark://0.0.0.0:7077

# 3. Validar conexión a Postgres antes de iniciar MLflow
echo "Esperando a que Postgres esté listo..."
max_retries=30
retry_count=0
until PGPASSWORD=mlflow_pass psql -h postgres_db -U mlflow_user -d mlflow_db -c "SELECT 1" 2>/dev/null || [ $retry_count -ge $max_retries ]; do
  retry_count=$((retry_count + 1))
  echo "Intento $retry_count/$max_retries: esperando a postgres..."
  sleep 2
done

if [ $retry_count -ge $max_retries ]; then
  echo "ADVERTENCIA: No se pudo conectar a postgres. MLflow puede fallar."
else
  echo "Postgres está listo."
fi

# 4. Iniciar MLflow Server en background con logs
echo "Iniciando MLflow Server..."
mlflow server \
    --host 0.0.0.0 \
    --port 5000 \
    --backend-store-uri postgresql://mlflow_user:mlflow_pass@postgres_db:5432/mlflow_db \
    --default-artifact-root file:///app/mlflow_artifacts > /var/log/mlflow.log 2>&1 &
MLFLOW_PID=$!
echo "MLflow iniciado con PID: $MLFLOW_PID"

# 5. Iniciar JupyterLab (Proceso principal que mantiene vivo el contenedor)
echo "Iniciando JupyterLab..."
exec jupyter lab \
    --ip=0.0.0.0 \
    --port=8888 \
    --no-browser \
    --allow-root \
    --NotebookApp.token="${JUPYTER_TOKEN}" \
    --notebook-dir=/app/notebooks