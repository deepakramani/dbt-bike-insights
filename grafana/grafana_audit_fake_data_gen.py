import csv
import random
from datetime import datetime, timedelta
from typing import List, Tuple

# Configuration
TABLES = [
    "raw_crm_cust_info",
    "raw_crm_prd_info",
    "raw_crm_sales_details",
    "raw_erp_loc_a101",
    "raw_erp_cust_az12",
    "raw_erp_px_cat_g1v2",
]

DAG_IDS = [
    "postgres_dwh_initial_load_dag",
    "incremental_load_dag",
    "daily_refresh_dag",
    "weekly_maintenance_dag",
    "emergency_reload_dag",
]

ERROR_MESSAGES = [
    "Connection timeout to source database",
    "File not found in staging directory",
    "Data validation failed - null values in required columns",
    "Duplicate key violation",
    "Memory limit exceeded during processing",
    "Source table locked by another process",
    "Network connectivity issues",
    "Insufficient disk space",
    "Data type conversion error",
    "Permission denied accessing source file",
]


def generate_realistic_record_count(table_name: str, load_type: str) -> int:
    """Generate realistic record counts based on table type and load type"""
    base_counts = {
        "raw_crm_cust_info": {"initial": 50000, "incremental": 1500},
        "raw_crm_prd_info": {"initial": 2500, "incremental": 150},
        "raw_crm_sales_details": {"initial": 500000, "incremental": 25000},
        "raw_erp_loc_a101": {"initial": 10000, "incremental": 800},
        "raw_erp_cust_az12": {"initial": 45000, "incremental": 1200},
        "raw_erp_px_cat_g1v2": {"initial": 500, "incremental": 25},
    }

    base = base_counts[table_name][load_type]
    # Add randomness: ±30% variation
    variation = random.uniform(0.7, 1.3)
    return int(base * variation)


def generate_filename(table_name: str, load_type: str, timestamp: datetime) -> str:
    """Generate realistic filenames for incremental loads"""
    if load_type == "initial":
        return ""

    # Extract table identifier from full table name
    table_part = table_name.replace("raw_", "").replace("crm_", "").replace("erp_", "")
    date_str = timestamp.strftime("%Y%m%d_%H%M")
    return f"{table_part}_inc_{date_str}.csv"


def generate_run_id(dag_id: str, timestamp: datetime, is_manual: bool = False) -> str:
    """Generate realistic Airflow run IDs"""
    if is_manual:
        return f"manual__{timestamp.strftime('%Y-%m-%dT%H:%M:%S.%f')[:-3]}+00:00"
    else:
        # Scheduled runs typically align to schedule intervals
        scheduled_time = timestamp.replace(
            minute=(timestamp.minute // 4) * 4, second=0, microsecond=0
        )
        return f"scheduled__{scheduled_time.strftime('%Y-%m-%dT%H:%M:%S')}+00:00"


def generate_load_duration() -> Tuple[float, float]:
    """Generate realistic load start and end times with proper duration"""
    # Load durations vary by complexity: 0.1s to 10 minutes
    duration_seconds = random.choice(
        [
            random.uniform(0.1, 2.0),  # Quick loads (60%)
            random.uniform(2.0, 30.0),  # Medium loads (30%)
            random.uniform(30.0, 600.0),  # Long loads (10%)
        ]
    )

    # Some variation in start time within the second
    start_offset = random.uniform(0, 0.999)

    return start_offset, start_offset + duration_seconds


def generate_audit_records(start_id: int = 12, num_records: int = 300) -> List[dict]:
    """Generate realistic audit log records"""
    records = []
    current_time = datetime(2025, 7, 2, 22, 15, 0)  # Start after existing data

    for i in range(num_records):
        audit_id = start_id + i

        # Choose table with weighted distribution (some tables load more frequently)
        table_weights = [
            3,
            1,
            4,
            2,
            3,
            1,
        ]  # sales_details and cust_info load more often
        table_name = random.choices(TABLES, weights=table_weights)[0]

        # Determine load type (incremental is much more common after initial loads)
        load_type = random.choices(["initial", "incremental"], weights=[5, 95])[0]

        # Choose DAG with realistic distribution
        if load_type == "initial":
            dag_id = "postgres_dwh_initial_load_dag"
        else:
            dag_weights = [50, 20, 15, 10, 5]  # incremental_load_dag is most common
            dag_id = random.choices(DAG_IDS, weights=dag_weights)[0]

        # Determine if manual or scheduled
        is_manual = (
            random.choice([True, False])
            if "manual" in dag_id or random.random() < 0.15
            else False
        )

        # Generate timing
        time_offset = timedelta(
            days=random.randint(0, 7),
            hours=random.randint(0, 23),
            minutes=random.randint(0, 59),
            seconds=random.randint(0, 59),
        )
        load_time = current_time + time_offset

        start_offset, end_offset = generate_load_duration()
        load_started_at = load_time + timedelta(seconds=start_offset)
        load_ended_at = load_time + timedelta(seconds=end_offset)
        load_timestamp = load_ended_at

        # Determine status (failures are uncommon but do happen)
        status_weights = [90, 8, 2]  # success, failed, timeout
        status = random.choices(
            ["success", "failed", "timeout"], weights=status_weights
        )[0]

        # Generate record count (0 for some incremental loads, especially failures)
        if status != "success":
            records_loaded = 0
        elif load_type == "incremental" and random.random() < 0.15:
            records_loaded = 0  # No new data to load
        else:
            records_loaded = generate_realistic_record_count(table_name, load_type)

        # Generate error message for failures
        error_message = ""
        if status in ["failed", "timeout"]:
            if status == "timeout":
                error_message = "Operation timed out after 300 seconds"
            else:
                error_message = random.choice(ERROR_MESSAGES)

        # Generate filename
        file_name = generate_filename(table_name, load_type, load_time)

        # Generate run_id
        run_id = generate_run_id(dag_id, load_time, is_manual)

        record = {
            "audit_id": audit_id,
            "table_name": table_name,
            "load_type": load_type,
            "records_loaded": records_loaded,
            "load_started_at": load_started_at.strftime("%Y-%m-%d %H:%M:%S.%f"),
            "load_ended_at": load_ended_at.strftime("%Y-%m-%d %H:%M:%S.%f"),
            "load_timestamp": load_timestamp.strftime("%Y-%m-%d %H:%M:%S.%f"),
            "status": status,
            "error_message": error_message,
            "file_name": file_name,
            "dag_id": dag_id,
            "run_id": run_id,
        }

        records.append(record)

        # Increment time for next record (small random intervals)
        current_time += timedelta(seconds=random.uniform(10, 300))

    return records


def save_to_csv(records: List[dict], filename: str = "generated_audit_logs1.csv"):
    """Save records to CSV file"""
    fieldnames = [
        "audit_id",
        "table_name",
        "load_type",
        "records_loaded",
        "load_started_at",
        "load_ended_at",
        "load_timestamp",
        "status",
        "error_message",
        "file_name",
        "dag_id",
        "run_id",
    ]

    with open(filename, "w", newline="", encoding="utf-8") as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(records)

    print(f"Generated {len(records)} audit log records and saved to {filename}")


def print_sample_records(records: List[dict], num_samples: int = 5):
    """Print a few sample records to verify output"""
    print(f"\nSample records (showing first {num_samples}):")
    print("-" * 120)

    for i, record in enumerate(records[:num_samples]):
        print(f"Record {i + 1}:")
        for key, value in record.items():
            print(f"  {key}: {value}")
        print()


def generate_summary_stats(records: List[dict]):
    """Print summary statistics of generated data"""
    print(f"\nSummary Statistics for {len(records)} records:")
    print("-" * 50)

    # Status distribution
    status_counts = {}
    for record in records:
        status = record["status"]
        status_counts[status] = status_counts.get(status, 0) + 1
    print("Status Distribution:")
    for status, count in status_counts.items():
        print(f"  {status}: {count} ({count / len(records) * 100:.1f}%)")

    # Load type distribution
    load_type_counts = {}
    for record in records:
        load_type = record["load_type"]
        load_type_counts[load_type] = load_type_counts.get(load_type, 0) + 1
    print("\nLoad Type Distribution:")
    for load_type, count in load_type_counts.items():
        print(f"  {load_type}: {count} ({count / len(records) * 100:.1f}%)")

    # Table distribution
    table_counts = {}
    for record in records:
        table = record["table_name"]
        table_counts[table] = table_counts.get(table, 0) + 1
    print("\nTable Distribution:")
    for table, count in sorted(table_counts.items()):
        print(f"  {table}: {count}")

    # DAG distribution
    dag_counts = {}
    for record in records:
        dag = record["dag_id"]
        dag_counts[dag] = dag_counts.get(dag, 0) + 1
    print("\nDAG Distribution:")
    for dag, count in sorted(dag_counts.items()):
        print(f"  {dag}: {count}")


if __name__ == "__main__":
    # Generate 300 audit log records starting from ID 22
    print("Generating 300 realistic audit log records...")

    audit_records = generate_audit_records(start_id=12, num_records=300)

    # Save to CSV
    save_to_csv(audit_records)

    # Show sample records
    print_sample_records(audit_records)

    # Generate summary statistics
    generate_summary_stats(audit_records)

    print(f"\nAll records have been generated and saved to 'generated_audit_logs.csv'")
    print("You can now append this data to your existing audit log table.")
