FROM apache/airflow:2.3.0

# Utilisation directe de l'utilisateur airflow (déjà configuré dans l’image officielle)
USER airflow


# Copier le fichier DAG (test_postgres_dag.py) dans le répertoire approprié de l'image
COPY ./dags/test_postgres_dag.py /opt/airflow/dags/

# Installer les dépendances nécessaires en une seule ligne
RUN pip install --no-cache-dir apache-airflow-providers-postgres

# Définir les variables d’environnement
ENV AIRFLOW_HOME=/opt/airflow
ENV AIRFLOW__CORE__SQL_ALCHEMY_CONN=postgresql+psycopg2://$POSTGRES_USER:$POSTGRES_PASSWORD@postgres:5432/$POSTGRES_DB
ENV AIRFLOW__CORE__EXECUTOR=LocalExecutor
ENV AIRFLOW__CORE__BASE_LOG_FOLDER=/opt/airflow/logs

# Exposer le port 8080 pour Airflow
EXPOSE 8080

# Lancer le webserver par défaut
ENTRYPOINT ["airflow"]
CMD ["webserver"]
