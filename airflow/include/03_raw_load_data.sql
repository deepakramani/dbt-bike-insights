/*
Loads the raw data into those tables. It leverages the bulk insert feature -- "COPY" of postgres to do faster insert into tables.
*/ 

COPY raw.raw_crm_cust_info(cst_id,cst_key,cst_firstname,cst_lastname,cst_marital_status,cst_gndr,cst_create_date,email,place_of_residence,postal_code)
FROM '/home/input_data/source_crm/cust_info_new.csv'
WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',');

COPY raw.raw_crm_prd_info(prd_id,prd_key,prd_nm,prd_cost,prd_line,prd_start_dt,prd_end_dt)
FROM '/home/input_data/source_crm/prd_info.csv'
WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',');

COPY raw.raw_crm_sales_details(sls_ord_num,sls_prd_key,sls_cust_id,sls_order_dt,sls_ship_dt,sls_due_dt,sls_sales,sls_quantity,sls_price)
FROM '/home/input_data/source_crm/sales_details.csv'
WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',');

COPY raw.raw_erp_loc_a101(CID,CNTRY)
FROM '/home/input_data/source_erp/loc_a101.csv'
WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',');

COPY raw.raw_erp_cust_az12(CID,BDATE,GEN)
FROM '/home/input_data/source_erp/cust_az12.csv'
WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',');

COPY raw.raw_erp_px_cat_g1v2(ID,CAT,SUBCAT,MAINTENANCE)
FROM '/home/input_data/source_erp/px_cat_g1v2.csv'
WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',');