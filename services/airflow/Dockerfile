FROM apache/airflow:2.3.0

# Passer en utilisateur airflow pour installer les paquets
USER airflow

# Installer psycopg2-binary sous l'utilisateur airflow
RUN pip install --no-cache-dir psycopg2-binary

# Revenir à root pour créer les dossiers nécessaires
USER root

RUN mkdir -p /opt/airflow/dags /opt/airflow/logs

# Définir les variables d’environnement
ENV AIRFLOW_HOME=/opt/airflow
ENV AIRFLOW__CORE__SQL_ALCHEMY_CONN=postgresql+psycopg2://$POSTGRES_USER:$POSTGRES_PASSWORD@postgres:5432/$POSTGRES_DB
ENV AIRFLOW__CORE__EXECUTOR=LocalExecutor
ENV AIRFLOW__CORE__BASE_LOG_FOLDER=/opt/airflow/logs

# Exposer le port 8080 pour Airflow
EXPOSE 8080

# Passer de nouveau à airflow pour exécuter Airflow
USER airflow

# Lancer le webserver
ENTRYPOINT ["airflow"]
CMD ["scheduler"]
