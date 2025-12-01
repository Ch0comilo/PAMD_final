# **Proyecto End-to-End: MLOps & Big Data Streaming Pipeline**

Este proyecto implementa una plataforma completa de **Ingeniería de Datos y MLOps** utilizando tecnologías de vanguardia contenerizadas con Docker. Simula un entorno productivo real para la ingesta, procesamiento, entrenamiento y orquestación de modelos de Machine Learning a escala.

## **🏗️ Arquitectura del Proyecto**

El sistema está diseñado de forma modular, donde cada componente cumple un rol específico en el ciclo de vida del dato:

1. **Ingesta en Tiempo Real (Apache Kafka):** Actúa como el bus de mensajería central. Recibe datos simulados (ej. viajes de taxi) y los disponibiliza para su consumo inmediato.  
2. **Procesamiento Distribuido (Apache Spark):**  
   * **Batch:** Procesa grandes volúmenes de datos históricos (archivos Parquet).  
   * **Streaming:** Consume datos en tiempo real desde Kafka para análisis al vuelo.  
3. **Gestión del Ciclo de Vida de ML (MLflow):** Rastrea experimentos, registra métricas/parámetros y versiona los modelos entrenados (Model Registry) utilizando PostgreSQL como backend.  
4. **Orquestación (Apache Airflow):** Programa y monitorea los flujos de trabajo (DAGs), asegurando que las tareas de ETL y re-entrenamiento se ejecuten en el orden y tiempo correctos.  
5. **Almacenamiento (PostgreSQL):** Base de datos relacional utilizada como *backend store* para los metadatos de Airflow y MLflow.

## **🚀 Servicios y Puertos**

Una vez desplegado el stack, podrás acceder a las siguientes interfaces web:

| Servicio | URL | Descripción |
| :---- | :---- | :---- |
| **JupyterLab** | http://localhost:8888 | Entorno de desarrollo (Notebooks). Token por defecto: hola-mundo. |
| **Spark Master** | http://localhost:8080 | Monitor del clúster de Spark y sus trabajadores. |
| **MLflow UI** | http://localhost:5000 | Interfaz para ver experimentos y modelos registrados. |
| **Airflow UI** | http://localhost:8081 | Gestión de DAGs y tareas. (User/Pass: admin/admin). |
| **Kafka** | localhost:9092 | Broker de mensajería (Acceso interno/externo configurado). |

## **📋 Requisitos Previos**

* **Docker Desktop** instalado y corriendo.  
  * *Recomendación:* Asignar al menos **6GB o 8GB de RAM** a Docker, ya que este stack es intensivo en memoria.  
* **Git** (opcional, para clonar el repo).

## **🛠️ Instalación y Despliegue**

1. Clonar/Descargar el proyecto:  
   Asegúrate de tener los archivos docker-compose.yml, Dockerfile y las carpetas notebooks/ y dags/ en la raíz.  
2. **Crear carpetas de volúmenes (si no existen):**  
   mkdir \-p dags notebooks

3. Construir y Levantar los contenedores:  
   Ejecuta el siguiente comando en la terminal dentro de la carpeta del proyecto:  
   docker-compose up \--build \-d

4. **Verificar estado:**  
   docker ps

   Todos los contenedores (python\_ml\_stack, kafka, airflow\_webserver, etc.) deben estar en estado "Up".**Nota:** Airflow puede tardar unos minutos en iniciar completamente mientras configura su base de datos.

## **📓 Guía de Uso Rápida**

### **1\. Exploración de Datos (Batch)**

Abre notebooks/Cuaderno Taller.ipynb. Este cuaderno descarga datos históricos de taxis de NY, realiza limpieza (ETL) y entrena un modelo de Clustering (K-Means) usando Spark MLlib.

### **2\. MLOps y Registro de Modelos**

Abre notebooks/Entrenamiento.ipynb. Aquí se entrena un modelo de clasificación (Regresión Logística) y se utiliza mlflow para registrar los parámetros, métricas y el modelo serializado.

* Verifica el registro en la UI de MLflow (http://localhost:5000).

### **3\. Streaming en Tiempo Real (Kafka \+ Spark)**

Abre notebooks/kafka\_spark\_streaming.ipynb.

* **Paso A:** Ejecuta las celdas del **Productor** para empezar a enviar datos sintéticos a Kafka.  
* **Paso B:** Ejecuta las celdas del **Consumidor (Spark Streaming)** para leer, procesar y visualizar esos datos en tiempo real.

### **4\. Orquestación (Airflow)**

Coloca tus scripts de Python (.py) dentro de la carpeta dags/.

* Accede a http://localhost:8081.  
* Activa el DAG y monitorea su ejecución gráfica.

## **🔧 Solución de Problemas Comunes**

* **Error de Memoria (OOM) / Contenedores se detienen:**  
  * Aumenta la RAM asignada a Docker Desktop (Settings \-\> Resources).  
* **Airflow pide credenciales o da error de DB:**  
  * Si cambiaste las contraseñas en el docker-compose.yml, es necesario borrar el volumen de la base de datos antigua para que se regenere:  
    docker-compose down \-\> docker volume rm \<nombre\_volumen\_postgres\> \-\> docker-compose up \-d.  
* **Spark no conecta a Kafka:**  
  * Asegúrate de usar KAFKA\_BROKER \= 'kafka:29092' dentro de los notebooks (comunicación interna de Docker).

Tecnologías: Python 3.11, Spark 3.5, MLflow, Kafka, Airflow, Docker.
