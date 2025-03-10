# Utilisation de l'image officielle d'Airflow
FROM apache/airflow:2.3.0

# Spécifie l'utilisateur qui va exécuter Airflow (facultatif)
USER root

# Installer des dépendances supplémentaires si nécessaire
RUN pip install --no-cache-dir psycopg2-binary

# Créer des répertoires pour stocker les DAGs et logs
RUN mkdir -p /opt/airflow/dags /opt/airflow/logs

# Définir l'emplacement des DAGs (ce répertoire sera monté avec un volume)
ENV AIRFLOW_HOME=/opt/airflow

# Définir les variables d'environnement nécessaires à la connexion à PostgreSQL
ENV AIRFLOW__CORE__SQL_ALCHEMY_CONN=postgresql+psycopg2://$POSTGRES_USER:$POSTGRES_PASSWORD@postgres:5432/$POSTGRES_DB
ENV AIRFLOW__CORE__EXECUTOR=LocalExecutor

# Définir le répertoire des logs
ENV AIRFLOW__CORE__BASE_LOG_FOLDER=/opt/airflow/logs

# Copier des DAGs ou des fichiers de configuration spécifiques, si nécessaire
# COPY ./dags /opt/airflow/dags

# Exposer le port 8080 pour accéder à l'interface web d'Airflow
EXPOSE 8080

# Lancer Airflow avec un gestionnaire de processus
ENTRYPOINT ["airflow"]
CMD ["webserver"]
