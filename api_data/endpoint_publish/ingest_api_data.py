import requests
import json
import psycopg2
import os
import hashlib
from psycopg2.extras import execute_values

POSTGRES_USER = os.getenv("POSTGRES_USER")
POSTGRES_PASSWORD = os.getenv("POSTGRES_PASSWORD")
POSTGRES_HOSTNAME = "127.0.0.1"
POSTGRES_DB = os.getenv("POSTGRES_DB")
POSTGRES_DB_PORT = os.getenv("POSTGRES_PORT")
SCHEMA = "raw"

CHUNK_SIZE = 10_000


def compute_json_hash(data_dict):
    """Compute SHA256 hash of sorted JSON string."""
    json_str = json.dumps(data_dict, sort_keys=True, separators=(",", ":"))
    return hashlib.sha256(json_str.encode("utf-8")).hexdigest()


def bulk_insert_api_data(records, table_name, pk_column, json_column, hash_column):
    """Insert api endpoints data into the database in chunks for appropriate primary keys."""
    if not records:
        print("No records to insert.")
        return

    insert_query = f"""
                    INSERT INTO {table_name}({pk_column}, {hash_column}, {json_column})
                    VALUES %s
                    ON CONFLICT ({hash_column}) DO NOTHING
                """

    try:
        with psycopg2.connect(
            database=POSTGRES_DB,
            user=POSTGRES_USER,
            password=POSTGRES_PASSWORD,
            host=POSTGRES_HOSTNAME,
            port=POSTGRES_DB_PORT,
            options=f"-c search_path={SCHEMA}",
        ) as conn:
            with conn.cursor() as cur:
                for i in range(0, len(records), CHUNK_SIZE):
                    chunk = records[i : i + CHUNK_SIZE]
                    execute_values(
                        cur=cur,
                        sql=insert_query,
                        argslist=chunk,
                    )
        print(f"Completed {table_name}: {len(records)} records processed")

    except Exception as e:
        print(f"Error during bulk insert into {table_name}: {e}")


if __name__ == "__main__":
    persona_records = requests.get(url="http://localhost:8000/persona").json()
    sales_tracking_records = requests.get(url="http://localhost:8000/tracking").json()

    # Process persona records
    cust_records = [
        (
            int(row["cst_id"]) if row.get("cst_id") not in (None, "", "null") else None,
            compute_json_hash({k: v for k, v in row.items() if k != "cst_id"}),
            json.dumps({k: v for k, v in row.items() if k != "cst_id"}),
        )
        for row in persona_records
    ]

    # Process tracking records
    tracking_records = [
        (
            row["sls_ord_num"],
            compute_json_hash({k: v for k, v in row.items() if k != "sls_ord_num"}),
            json.dumps({k: v for k, v in row.items() if k != "sls_ord_num"}),
        )
        for row in sales_tracking_records
    ]

    # Bulk insert operations
    bulk_insert_api_data(
        cust_records,
        table_name="raw_api_persona",
        pk_column="cst_id",
        json_column="cst_data",
        hash_column="cst_data_hash",
    )

    bulk_insert_api_data(
        tracking_records,
        table_name="raw_api_sales_tracking",
        pk_column="sls_ord_num",
        json_column="tracking_data",
        hash_column="tracking_data_hash",
    )
