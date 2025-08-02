DROP TABLE IF EXISTS raw.raw_api_persona;
CREATE TABLE IF NOT EXISTS raw.raw_api_persona(
    cst_id INT,
    cst_data jsonb,
    cst_data_hash TEXT UNIQUE,
    ingested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS raw.raw_api_sales_tracking;
CREATE TABLE IF NOT EXISTS raw.raw_api_sales_tracking(
    sls_ord_num VARCHAR(50),
    tracking_data jsonb,
    tracking_data_hash TEXT UNIQUE,
    ingested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);