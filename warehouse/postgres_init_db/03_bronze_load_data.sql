/*
Loads the raw data into those tables. It leverages the bulk insert feature -- "COPY" of postgres to do faster insert into tables.
*/ 

\c sql_dwh_db;

COPY bronze.crm_cust_info
FROM '/home/input_data/source_crm/cust_info_new.csv'
WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',');

COPY bronze.crm_prd_info
FROM '/home/input_data/source_crm/prd_info.csv'
WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',');

COPY bronze.crm_sales_details
FROM '/home/input_data/source_crm/sales_details.csv'
WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',');

COPY bronze.erp_loc_a101
FROM '/home/input_data/source_erp/loc_a101.csv'
WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',');

COPY bronze.erp_cust_az12
FROM '/home/input_data/source_erp/cust_az12.csv'
WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',');

COPY bronze.erp_px_cat_g1v2
FROM '/home/input_data/source_erp/px_cat_g1v2.csv'
WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',');