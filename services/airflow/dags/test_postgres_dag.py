from airflow import DAG
from airflow.providers.postgres.operators.postgres import PostgresOperator
from airflow.operators.python import PythonOperator
from datetime import datetime
from airflow.hooks.postgres_hook import PostgresHook

# Fonction pour récupérer et afficher la version de PostgreSQL
def fetch_postgres_version():
    hook = PostgresHook(postgres_conn_id="postgres_default")
    conn = hook.get_conn()
    cursor = conn.cursor()
    cursor.execute("SELECT version();")
    version = cursor.fetchone()
    print(f"PostgreSQL version: {version[0]}")

# Définition du DAG
default_args = {
    "owner": "airflow",
    "start_date": datetime(2024, 1, 1),
    "retries": 1,
}

with DAG(
    dag_id="test_postgres_dag",
    default_args=default_args,
    schedule_interval="@daily",
    catchup=False,
) as dag:

    # Vérifier la connexion à PostgreSQL
    check_postgres = PostgresOperator(
        task_id="check_postgres_connection",
        postgres_conn_id="postgres_default",
        sql="SELECT 1;",
    )

    # Récupérer la version de PostgreSQL
    get_postgres_version = PythonOperator(
        task_id="fetch_postgres_version",
        python_callable=fetch_postgres_version,
    )

    # Orchestration des tâches
    check_postgres >> get_postgres_version
