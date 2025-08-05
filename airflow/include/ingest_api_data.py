from psycopg2.extras import execute_values
from airflow.providers.postgres.hooks.postgres import PostgresHook
import os
import requests
import logging
import json
import hashlib

CHUNK_SIZE = 10_000
API_KEY = os.getenv("API_KEY")
HEADERS = {"x-api-key": API_KEY}
# BASE_URL = "http://host.docker.internal:8000"
BASE_URL = "http://api_service:8000"  # when using docker container

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(message)s")


def compute_json_hash(data_dict):
    """Compute SHA256 hash of sorted JSON string."""
    json_str = json.dumps(data_dict, sort_keys=True, separators=(",", ":"))
    return hashlib.sha256(json_str.encode("utf-8")).hexdigest()


def _insert_records(
    records,
    table_name,
    pk_column,
    json_column,
    hash_column,
    conn_id="postgres_dwh_conn",
):
    if not records:
        print("No records to insert.")
        return
    schema_name = os.getenv("POSTGRES_SCHEMA", "raw")  # Ensure schema is set
    insert_query = f"""
                    INSERT INTO {schema_name}.{table_name}({pk_column}, {hash_column}, {json_column})
                    VALUES %s
                    ON CONFLICT ({hash_column}) DO NOTHING
                """
    hook = PostgresHook(postgres_conn_id=conn_id)
    conn = hook.get_conn()
    try:
        with conn.cursor() as cur:
            for i in range(0, len(records), CHUNK_SIZE):
                chunk = records[i : i + CHUNK_SIZE]
                execute_values(
                    cur=cur,
                    sql=insert_query,
                    argslist=chunk,
                )
        conn.commit()
        logging.info(f"Completed {table_name}: {len(records)} records processed")
    except Exception as e:
        logging.error(f"Error during bulk insert into {table_name}: {e}")
        raise


def fetch_api(endpoint: str):
    """Fetch data from API with retry on 429 (rate limit)."""
    url = f"{BASE_URL}/{endpoint}"
    resp = requests.get(url, headers=HEADERS)
    logging.info(f"GET {url} -> {resp.status_code}")
    return resp


def bulk_insert_api_data(**context):
    """Airflow task to insert API data"""

    # Fetch persona data
    persona_resp = fetch_api("raw_api_persona")
    if persona_resp.status_code != 200:
        raise Exception(f"Persona API failed: {persona_resp.status_code}")

    # Fetch sales data
    sales_tracking_resp = fetch_api("raw_api_sales_tracking")
    if sales_tracking_resp.status_code != 200:
        raise Exception(f"Sales API failed: {sales_tracking_resp.status_code}")

    if persona_resp.status_code == 429 or sales_tracking_resp.status_code == 429:
        logging.warning(
            "API rate limit exceeded. Please check the API service or increase the limit."
        )
    persona_records = persona_resp.json()
    sales_tracking_records = sales_tracking_resp.json()

    # Process persona records
    cust_records = [
        (
            int(row["cst_id"]) if row.get("cst_id") not in (None, "", "null") else None,
            compute_json_hash({k: v for k, v in row.items() if k != "cst_id"}),
            json.dumps({k: v for k, v in row.items() if k != "cst_id"}),
        )
        for row in persona_records
    ]

    # print(cust_records[0:5])  # Debugging: print first 5 records
    # Process tracking records
    tracking_records = [
        (
            row["sls_ord_num"],
            compute_json_hash({k: v for k, v in row.items() if k != "sls_ord_num"}),
            json.dumps({k: v for k, v in row.items() if k != "sls_ord_num"}),
        )
        for row in sales_tracking_records
    ]

    # Insert data
    _insert_records(
        cust_records, "raw_api_persona", "cst_id", "cst_data", "cst_data_hash"
    )

    _insert_records(
        tracking_records,
        "raw_api_sales_tracking",
        "sls_ord_num",
        "tracking_data",
        "tracking_data_hash",
    )

    logging.info(
        f"Successfully ingested {len(cust_records)} persona records and {len(tracking_records)} tracking records"
    )
