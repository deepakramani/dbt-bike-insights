/*
This sql script creates raw layer tables and monitoring tables for auditing data loads.
*/


DROP TABLE IF EXISTS raw.raw_crm_cust_info;
CREATE TABLE IF NOT EXISTS raw.raw_crm_cust_info(
    cst_id INT,
    cst_key VARCHAR(50),
    cst_firstname VARCHAR(50),
    cst_lastname VARCHAR(50),
    cst_marital_status VARCHAR(50),
    cst_gndr VARCHAR(50),
    cst_create_date DATE,
    email VARCHAR(100),
    place_of_residence VARCHAR(50),
    postal_code INT,
    ingested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS raw.raw_crm_prd_info;
CREATE TABLE IF NOT EXISTS raw.raw_crm_prd_info (
    prd_id       INT,
    prd_key      VARCHAR(50),
    prd_nm       VARCHAR(50),
    prd_cost     INT,
    prd_line     VARCHAR(50),
    prd_start_dt TIMESTAMP,
    prd_end_dt   TIMESTAMP,
    ingested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS raw.raw_crm_sales_details;
CREATE TABLE IF NOT EXISTS raw.raw_crm_sales_details (
    sls_ord_num  VARCHAR(50),
    sls_prd_key  VARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt INT,
    sls_ship_dt  INT,
    sls_due_dt   INT,
    sls_sales    INT,
    sls_quantity INT,
    sls_price    INT,
    ingested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS raw.raw_erp_loc_a101;
CREATE TABLE IF NOT EXISTS raw.raw_erp_loc_a101 (
    cid    VARCHAR(50),
    cntry  VARCHAR(50),
    ingested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS raw.raw_erp_cust_az12;
CREATE TABLE IF NOT EXISTS raw.raw_erp_cust_az12 (
    cid    VARCHAR(50),
    bdate  DATE,
    gen    VARCHAR(50),
    ingested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS raw.raw_erp_px_cat_g1v2;
CREATE TABLE IF NOT EXISTS raw.raw_erp_px_cat_g1v2 (
    id           VARCHAR(50),
    cat          VARCHAR(50),
    subcat       VARCHAR(50),
    maintenance  VARCHAR(50),
    ingested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS monitoring.ingest_audit_log;
CREATE TABLE IF NOT EXISTS monitoring.ingest_audit_log (
    audit_id SERIAL PRIMARY KEY,
    table_name VARCHAR(100),
    load_type TEXT CHECK (load_type IN ('initial', 'incremental', 'backfill')),
    records_loaded INTEGER,
    load_started_at TIMESTAMP NOT NULL,
    load_ended_at TIMESTAMP NOT NULL,
    load_timestamp TIMESTAMP,
    status VARCHAR(20),
    error_message TEXT,
    file_name TEXT, -- optional, useful for file-based ingestion
    dag_id TEXT,  -- Airflow DAG name
    run_id TEXT   -- Airflow run_id (execution context)
);


CREATE OR REPLACE FUNCTION monitoring.ingest_audit_log(
    p_table_name TEXT,
    p_is_full_load BOOLEAN DEFAULT false,
    p_dag_id TEXT DEFAULT NULL,
    p_run_id TEXT DEFAULT NULL,
    p_file_name TEXT DEFAULT NULL
)
RETURNS VOID AS $$
DECLARE
    v_count INTEGER;
    v_last_audit_time TIMESTAMP;
    v_load_start TIMESTAMP := clock_timestamp();
    v_load_end TIMESTAMP;
    v_load_type TEXT;
    v_valid_tables TEXT[] := ARRAY[
        'raw_crm_cust_info',
        'raw_crm_prd_info',
        'raw_crm_sales_details',
        'raw_erp_loc_a101',
        'raw_erp_cust_az12',
        'raw_erp_px_cat_g1v2'
    ];
BEGIN
    -- Validate table name
    IF NOT p_table_name = ANY(v_valid_tables) THEN
        RAISE EXCEPTION 'Invalid table name: %', p_table_name;
    END IF;

    -- Set load type
    v_load_type := CASE
        WHEN p_is_full_load THEN 'initial'
        ELSE 'incremental'
    END;

    -- Count records
    IF p_is_full_load THEN
        v_count := CASE p_table_name
            WHEN 'raw_crm_cust_info' THEN (SELECT COUNT(*) FROM raw.raw_crm_cust_info)
            WHEN 'raw_crm_prd_info' THEN (SELECT COUNT(*) FROM raw.raw_crm_prd_info)
            WHEN 'raw_crm_sales_details' THEN (SELECT COUNT(*) FROM raw.raw_crm_sales_details)
            WHEN 'raw_erp_loc_a101' THEN (SELECT COUNT(*) FROM raw.raw_erp_loc_a101)
            WHEN 'raw_erp_cust_az12' THEN (SELECT COUNT(*) FROM raw.raw_erp_cust_az12)
            WHEN 'raw_erp_px_cat_g1v2' THEN (SELECT COUNT(*) FROM raw.raw_erp_px_cat_g1v2)
        END;
    ELSE
        SELECT COALESCE(MAX(load_timestamp), '1970-01-01'::timestamp)
        INTO v_last_audit_time
        FROM monitoring.ingest_audit_log
        WHERE table_name = p_table_name;

        v_count := CASE p_table_name
            WHEN 'raw_crm_cust_info' THEN (
                SELECT COUNT(*) FROM raw.raw_crm_cust_info WHERE ingested_at > v_last_audit_time)
            WHEN 'raw_crm_prd_info' THEN (
                SELECT COUNT(*) FROM raw.raw_crm_prd_info WHERE ingested_at > v_last_audit_time)
            WHEN 'raw_crm_sales_details' THEN (
                SELECT COUNT(*) FROM raw.raw_crm_sales_details WHERE ingested_at > v_last_audit_time)
            WHEN 'raw_erp_loc_a101' THEN (
                SELECT COUNT(*) FROM raw.raw_erp_loc_a101 WHERE ingested_at > v_last_audit_time)
            WHEN 'raw_erp_cust_az12' THEN (
                SELECT COUNT(*) FROM raw.raw_erp_cust_az12 WHERE ingested_at > v_last_audit_time)
            WHEN 'raw_erp_px_cat_g1v2' THEN (
                SELECT COUNT(*) FROM raw.raw_erp_px_cat_g1v2 WHERE ingested_at > v_last_audit_time)
        END;
    END IF;

    v_load_end := clock_timestamp();

    -- Insert success audit record
    INSERT INTO monitoring.ingest_audit_log (
        table_name,
        load_type,
        records_loaded,
        load_started_at,
        load_ended_at,
        load_timestamp,
        status,
        error_message,
        file_name,
        dag_id,
        run_id
    ) VALUES (
        p_table_name,
        v_load_type,
        v_count,
        v_load_start,
        v_load_end,
        v_load_end,  -- same as ended_at
        'success',
        NULL,
        p_file_name,
        p_dag_id,
        p_run_id
    );

EXCEPTION
    WHEN OTHERS THEN
        v_load_end := clock_timestamp();
        -- Insert failure audit
        INSERT INTO monitoring.ingest_audit_log (
            table_name,
            load_type,
            records_loaded,
            load_started_at,
            load_ended_at,
            load_timestamp,
            status,
            error_message,
            file_name,
            dag_id,
            run_id
        ) VALUES (
            p_table_name,
            v_load_type,
            0,
            v_load_start,
            v_load_end,
            v_load_end,
            'failed',
            SQLERRM,
            p_file_name,
            p_dag_id,
            p_run_id
        );
        RAISE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
