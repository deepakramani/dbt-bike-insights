"""
Incremental loader DAG
- finds any CSV whose name contains the table prefix
- runs every minute for quick testing
"""

from datetime import datetime
import os
import glob
import shutil

from airflow.decorators import dag, task
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator

DATABASE_CONN_ID = "postgres_dwh_conn"

AIRFLOW_MOUNT = "/usr/local/airflow/input_data/landing/incremental"
POSTGRES_MOUNT = "/home/input_data/landing/incremental"

# table  ->  (subdir,  prefix)
TABLES = {
    "raw_crm_cust_info": ("crm", "cust_info"),
    "raw_erp_loc_a101": ("erp", "loc_a101"),
}

# columns in the same order as the CSV headers
COLS = {
    "raw_crm_cust_info": "cst_id,cst_key,cst_firstname,cst_lastname,cst_marital_status,"
    "cst_gndr,cst_create_date,email,place_of_residence,postal_code",
    "raw_erp_loc_a101": "loc_id,loc_name,loc_address,loc_city,loc_country,loc_type",
}


@task
def get_sql() -> tuple[str, list[str]]:
    """Return (sql_string)"""
    copy_stmts: list[str] = []

    for tbl, (subdir, prefix) in TABLES.items():
        pattern = os.path.join(AIRFLOW_MOUNT, subdir, f"{prefix}*.csv")
        files = sorted(glob.glob(pattern))
        if not files:
            continue
        for fp in files:
            pg_fp = fp.replace(AIRFLOW_MOUNT, POSTGRES_MOUNT)
            copy_stmts.append(
                f"COPY raw.{tbl}({COLS[tbl]}) FROM '{pg_fp}' "
                "WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',');"
            )
    return "\n".join(copy_stmts) if copy_stmts else "SELECT 1;"


@task
def get_tables() -> list[str]:
    """Return list of tables with files"""
    loaded_tables: list[str] = []
    for tbl, (subdir, prefix) in TABLES.items():
        pattern = os.path.join(AIRFLOW_MOUNT, subdir, f"{prefix}*.csv")
        files = sorted(glob.glob(pattern))
        if files:
            loaded_tables.append(tbl)
    return loaded_tables


@task(trigger_rule="all_success")
def move_processed() -> None:
    for _, (subdir, prefix) in TABLES.items():
        src_dir = os.path.join(AIRFLOW_MOUNT, subdir)
        dst_dir = os.path.join(AIRFLOW_MOUNT, subdir, "processed")
        os.makedirs(dst_dir, exist_ok=True)
        for fp in glob.glob(os.path.join(src_dir, f"{prefix}*.csv")):
            shutil.move(fp, os.path.join(dst_dir, os.path.basename(fp)))


@task(trigger_rule="one_failed")
def move_failed() -> None:
    for _, (subdir, prefix) in TABLES.items():
        src_dir = os.path.join(AIRFLOW_MOUNT, subdir)
        dst_dir = os.path.join(AIRFLOW_MOUNT, subdir, "failed")
        os.makedirs(dst_dir, exist_ok=True)
        for fp in glob.glob(os.path.join(src_dir, f"{prefix}*.csv")):
            shutil.move(fp, os.path.join(dst_dir, os.path.basename(fp)))


@dag(
    dag_id="incremental_load_dag",
    start_date=datetime(2025, 1, 1),
    schedule=None,  # "* * * * *",  # every minute
    catchup=False,
)
def incremental_load_dag():
    sql_stmt = get_sql()
    table_task = get_tables()
    load_task = SQLExecuteQueryOperator(
        task_id="load_files",
        conn_id=DATABASE_CONN_ID,
        sql=sql_stmt,
        autocommit=True,
    )

    audit_task = SQLExecuteQueryOperator.partial(
        task_id="audit_table",
        conn_id=DATABASE_CONN_ID,
        autocommit=True,
    ).expand(
        sql=table_task.map(  # Access loaded_tables and map to SQL statements
            lambda tbl: f"SELECT monitoring.audit_table_load('{tbl}', false);"
        )
    )

    mv_proc = move_processed()
    mv_fail = move_failed()

    load_task >> audit_task >> mv_proc
    load_task >> mv_fail


dag = incremental_load_dag()
