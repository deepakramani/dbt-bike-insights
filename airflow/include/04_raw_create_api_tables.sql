DROP TABLE raw.raw_api_persona;
CREATE TABLE raw.raw_api_persona(
    cst_id INT,
    cst_data jsonb,
    cst_data_hash TEXT UNIQUE
);

DROP TABLE raw.raw_api_sales_tracking;
CREATE TABLE raw.raw_api_sales_tracking(
    sls_ord_num VARCHAR(50),
    tracking_data jsonb,
    tracking_data_hash TEXT UNIQUE
);