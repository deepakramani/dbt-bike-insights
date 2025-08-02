from datetime import datetime, timedelta
from airflow.decorators import dag, task
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "include"))
from ingest_api_data import bulk_insert_api_data

DB_CONN = "postgres_dwh_conn"


@dag(
    dag_id="api_data_ingestion",
    description="Ingest customer and sales tracking data from API to PostgreSQL (persona + sales_tracking)",
    start_date=datetime(2025, 8, 1),
    schedule=None,  # timedelta(hours=1),
    catchup=False,
    tags=["customer", "ingestion", "api"],
    template_searchpath=["/usr/local/airflow/include"],
    default_args={
        "owner": "airflow",
        "depends_on_past": False,
        "email_on_failure": False,
        "email_on_retry": False,
        "retries": 1,
        "retry_delay": timedelta(minutes=5),
    },
)
def customer_data_ingestion():
    @task(task_id="create_raw_api_tables")
    def create_raw_api_tables():
        """
        Create the raw API tables for customer persona and sales tracking.
        """
        SQLExecuteQueryOperator(
            task_id="create_raw_api_persona_table",
            conn_id=DB_CONN,
            sql="04_raw_create_api_tables.sql",
            autocommit=True,
        )

    @task(task_id="ingest_api_attributes_data")
    def ingest():
        """
        Re-use the existing bulk_insert_api_data() which loads
        raw_api_persona and raw_api_sales_tracking.
        No code changes required there.
        """
        bulk_insert_api_data()

    @task(trigger_rule="all_success")
    def log_audit(**context) -> None:
        """
        Write one audit row for each target table.
        """
        dag_id = context["dag"].dag_id
        run_id = context["run_id"]

        audit_tables = {
            "raw_api_persona": "cust_info_with_attributes.json",
            "raw_api_sales_tracking": "sales_details_with_attributes.json",
        }

        for tbl, filename in audit_tables.items():
            audit_sql = f"SELECT monitoring.ingest_audit_log('{tbl}', true, '{dag_id}', '{run_id}', '{filename}');"
            SQLExecuteQueryOperator(
                task_id=f"audit_insert{tbl}",
                conn_id=DB_CONN,
                sql=audit_sql,
                autocommit=True,
            )

    # Flow
    create_task = create_raw_api_tables()
    ingest_task = ingest()
    audit_task = log_audit()

    create_task >> ingest_task >> audit_task


# Instantiate the DAG
customer_data_ingestion()
