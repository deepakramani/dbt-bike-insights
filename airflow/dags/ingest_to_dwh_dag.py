from datetime import datetime
from airflow import DAG
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator


DATABASE_CONN_ID = "postgres_dwh_conn"

# SQL files are directly accessible in the include directory
SQL_CREATE_DB = "01_create_raw_schema.sql"
SQL_CREATE_TABLES = "02_raw_create_tables.sql"
SQL_LOAD_DATA = "03_raw_load_data.sql"

# Base DAG arguments
default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "email_on_failure": False,
    "email_on_retry": False,
    "retries": 1,
}

with DAG(
    dag_id="postgres_dwh_ingestion_pipeline",
    description="Pipeline to create database, schema, tables and load data from CSV files",
    default_args=default_args,
    start_date=datetime(2025, 1, 1),
    catchup=False,
    tags=["ingestion"],
    template_searchpath=["/usr/local/airflow/include"],
) as dag:
    # Create database and schema
    create_db_schema = SQLExecuteQueryOperator(
        task_id="create_raw_db_schema",
        conn_id=DATABASE_CONN_ID,
        sql=SQL_CREATE_DB,
        autocommit=True,
    )

    # Create tables in schema
    create_tables = SQLExecuteQueryOperator(
        task_id="create_raw_tables",
        conn_id=DATABASE_CONN_ID,
        sql=SQL_CREATE_TABLES,
        autocommit=True,
    )

    # Load data using COPY command
    # The SQL file has COPY commands using the mounted CSV location
    load_data = SQLExecuteQueryOperator(
        task_id="load_raw_data",
        conn_id=DATABASE_CONN_ID,
        sql=SQL_LOAD_DATA,
        autocommit=True,
    )

    # Set task dependencies
    (create_db_schema >> create_tables >> load_data)
