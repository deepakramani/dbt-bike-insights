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


DROP TABLE IF EXISTS monitoring.load_audit;
CREATE TABLE IF NOT EXISTS monitoring.load_audit (
    table_name VARCHAR(100),
    load_timestamp TIMESTAMP,
    records_loaded INTEGER,
    status VARCHAR(20),
    error_message TEXT
);

CREATE OR REPLACE FUNCTION monitoring.audit_table_load(p_table_name text, p_is_full_load boolean DEFAULT false)
RETURNS void AS $$
DECLARE
    v_count integer;
    v_last_audit_time timestamp;
    v_valid_tables text[] := ARRAY[
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

    IF p_is_full_load THEN
        -- For full loads, count all rows
        v_count := CASE p_table_name
            WHEN 'raw_crm_cust_info' THEN (SELECT COUNT(*) FROM raw.raw_crm_cust_info)
            WHEN 'raw_crm_prd_info' THEN (SELECT COUNT(*) FROM raw.raw_crm_prd_info)
            WHEN 'raw_crm_sales_details' THEN (SELECT COUNT(*) FROM raw.raw_crm_sales_details)
            WHEN 'raw_erp_loc_a101' THEN (SELECT COUNT(*) FROM raw.raw_erp_loc_a101)
            WHEN 'raw_erp_cust_az12' THEN (SELECT COUNT(*) FROM raw.raw_erp_cust_az12)
            WHEN 'raw_erp_px_cat_g1v2' THEN (SELECT COUNT(*) FROM raw.raw_erp_px_cat_g1v2)
        END;
    ELSE
        -- Get last audit time for incremental loads
        SELECT COALESCE(MAX(load_timestamp), '1970-01-01'::timestamp)
        INTO v_last_audit_time
        FROM monitoring.load_audit
        WHERE table_name = p_table_name;

        -- Count only new rows since last audit
        v_count := CASE p_table_name
            WHEN 'raw_crm_cust_info' THEN (
                SELECT COUNT(*) 
                FROM raw.raw_crm_cust_info 
                WHERE ingested_at > v_last_audit_time
            )
            WHEN 'raw_crm_prd_info' THEN (
                SELECT COUNT(*) 
                FROM raw.raw_crm_prd_info 
                WHERE ingested_at > v_last_audit_time
            )
            WHEN 'raw_crm_sales_details' THEN (
                SELECT COUNT(*) FROM raw.raw_crm_sales_details WHERE ingested_at > v_last_audit_time
            )
            WHEN 'raw_erp_loc_a101' THEN (
                SELECT COUNT(*) FROM raw.raw_erp_loc_a101 WHERE ingested_at > v_last_audit_time
            )
            WHEN 'raw_erp_cust_az12' THEN (
                SELECT COUNT(*) FROM raw.raw_erp_cust_az12 WHERE ingested_at > v_last_audit_time
            )
            WHEN 'raw_erp_px_cat_g1v2' THEN (
                SELECT COUNT(*) FROM raw.raw_erp_px_cat_g1v2 WHERE ingested_at > v_last_audit_time
            )
        END;
    END IF;

    -- Record the audit with load type
    INSERT INTO monitoring.load_audit (
        table_name,
        load_timestamp,
        records_loaded,
        status,
        error_message
    ) VALUES (
        p_table_name,
        CURRENT_TIMESTAMP,
        v_count,
        CASE 
            WHEN p_is_full_load THEN 'FULL_LOAD_SUCCESS'
            ELSE 'INCREMENTAL_SUCCESS'
        END,
        NULL
    );
    EXCEPTION
        WHEN OTHERS THEN
            -- Log error in load audit table
            INSERT INTO monitoring.load_audit (
                table_name,
                load_timestamp,
                records_loaded,
                status,
                error_message
            ) VALUES (
                p_table_name,
                CURRENT_TIMESTAMP,
                0,
                'LOAD_FAILED',
                format('Error: %s. Detail: %s. Hint: %s', 
                    SQLERRM,
                    SQLSTATE                
                )
            );
            RAISE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;