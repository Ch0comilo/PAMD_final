-- Crear usuario mlflow_user (ignorar si ya existe)
CREATE ROLE mlflow_user WITH LOGIN PASSWORD 'mlflow_pass';

-- Crear base de datos mlflow_db
CREATE DATABASE mlflow_db OWNER mlflow_user;

-- Dar permisos al usuario sobre la base de datos
GRANT ALL PRIVILEGES ON DATABASE mlflow_db TO mlflow_user;
