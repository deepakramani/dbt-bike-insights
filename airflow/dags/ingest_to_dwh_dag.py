from datetime import datetime
from airflow import DAG
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator

DATABASE_CONN_ID = "postgres_dwh_conn"

AUDIT_TABLES = {
    "raw_crm_cust_info": "cust_info_1.csv",
    "raw_crm_prd_info": "prd_info_1.csv",
    "raw_crm_sales_details": "sales_details_1.csv",
    "raw_erp_loc_a101": "loc_a101_1.csv",
    "raw_erp_cust_az12": "cust_az12_1.csv",
    "raw_erp_px_cat_g1v2": "px_cat_g1v2_1.csv",
}

default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "email_on_failure": False,
    "email_on_retry": False,
    "retries": 1,
}

with DAG(
    dag_id="postgres_dwh_initial_load_dag",
    description="Create DB, load tables and audit load",
    default_args=default_args,
    start_date=datetime(2025, 1, 1),
    catchup=False,
    tags=["initial", "ingestion"],
    template_searchpath=["/usr/local/airflow/include"],
) as dag:
    create_db_schema = SQLExecuteQueryOperator(
        task_id="create_raw_db_schema",
        conn_id=DATABASE_CONN_ID,
        sql="01_create_raw_schema.sql",
        autocommit=True,
    )

    create_tables = SQLExecuteQueryOperator(
        task_id="create_raw_tables",
        conn_id=DATABASE_CONN_ID,
        sql="02_raw_create_tables.sql",
        autocommit=True,
    )

    load_data = SQLExecuteQueryOperator(
        task_id="load_raw_data",
        conn_id=DATABASE_CONN_ID,
        sql="03_raw_load_data.sql",
        autocommit=True,
    )

    audit_tasks = []
    for table in AUDIT_TABLES:
        audit_sql = (
            "SELECT monitoring.ingest_audit_log("
            f"'{table}', true, '{dag.dag_id}', '{{{{ run_id }}}}', '{AUDIT_TABLES[table]}'"
            ");"
        )
        audit_task = SQLExecuteQueryOperator(
            task_id=f"audit_{table}",
            conn_id=DATABASE_CONN_ID,
            sql=audit_sql,
            autocommit=True,
        )
        audit_tasks.append(audit_task)

    create_db_schema >> create_tables >> load_data >> audit_tasks
