
      
  
    

  create  table "sql_dwh_db"."silver"."crm_sales_details"
  
  
    as
  
  (
    
-- Configures the model to enforce a unique key on sls_ord_num, though this is more informational since deduplication happens within the query via ROW_NUMBER(). This signals intent to DBT for potential optimizations or downstream checks.

WITH deduped AS (
    -- Purpose: Removes duplicate sales records from the bronze layer, keeping only the most recent entry
    -- for each unique combination of order number (sls_ord_num) and product key (sls_prd_key).
    SELECT *
    FROM (
        SELECT 
            *,
            -- ROW_NUMBER assigns a unique number to each row within a partition of sls_ord_num and sls_prd_key,
            -- ordered by updated_at DESC to prioritize the latest record. This ensures we handle cases where
            -- the same order-product pair appears multiple times due to updates or ingestion errors.
            ROW_NUMBER() OVER (PARTITION BY sls_ord_num, sls_prd_key ORDER BY updated_at DESC) AS rn
        FROM "sql_dwh_db"."bronze"."bz_crm_sales_details"  
        -- References the bronze table with raw sales data, 
        -- already converted to DATE types from INT.
    ) t
    WHERE rn = 1  
    -- Filters to keep only the first row (latest record) per partition, effectively deduplicating.
),

product_lifecycle AS (
    -- Purpose: Joins sales data with product lifecycle info to determine the active lifecycle period 
    -- for each sale, handling cases where a product (sls_prd_key) has multiple start/end dates in crm_prd_info.
    SELECT 
        d.sls_ord_num,
        d.sls_prd_key,
        d.sls_cust_id,
        d.sls_order_dt,  -- Comes from bronze as DATE or NULL (e.g., 0 → NULL).
        d.sls_ship_dt,   -- Comes from bronze as DATE, validated as non-NULL in WHERE clause.
        d.sls_due_dt,
        d.sls_quantity,
        d.sls_price,
        d.sls_sales,
        d.ingested_at,
        d.updated_at,
        p.prd_start_date,  -- Product lifecycle start date from crm_prd_info.
        p.prd_end_date,    -- Product lifecycle end date from crm_prd_info.
        -- ROW_NUMBER ranks lifecycle rows for each sls_ord_num, sls_prd_key pair. 
        -- The CASE prioritizes lifecycles where sls_ship_dt falls within prd_start_date and prd_end_date (rn = 1),
        -- falling back to the latest end date (DESC) if no match (rn > 1). This ensures we pick the active 
        -- lifecycle for the shipment date, addressing multiple lifecycle entries per product.
        ROW_NUMBER() OVER (PARTITION BY d.sls_ord_num, d.sls_prd_key 
                          ORDER BY CASE 
                                      WHEN d.sls_ship_dt >= p.prd_start_date 
                                           AND d.sls_ship_dt < p.prd_end_date 
                                      THEN 1 
                                      ELSE 2 
                                  END, p.prd_end_date DESC) AS rn
    FROM deduped d
    LEFT JOIN "sql_dwh_db"."silver"."crm_prd_info" p  
    -- LEFT JOIN ensures all sales records are kept, even if no 
    -- product info exists, though all sls_prd_key values should match.
        ON d.sls_prd_key = p.prd_code
    WHERE d.sls_ship_dt IS NOT NULL  
    -- Ensures we only process rows with a valid shipment date, as this is 
    -- critical for lifecycle checks and fallback for sls_order_dt.
),

cleaned_sales_dates AS (
    -- Purpose: Cleans and finalizes date fields, ensuring sls_order_dt is populated correctly using 
    -- sls_ship_dt when needed, based on the active product lifecycle.
    SELECT 
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        -- CASE logic for sls_order_dt:
        -- 1. If sls_order_dt is not NULL (valid from bronze), use it as-is.
        -- 2. If sls_order_dt is NULL and sls_ship_dt falls within the active lifecycle (ensured by rn = 1),
        --    use sls_ship_dt as a fallback. This addresses cases where the original order date was invalid (e.g., 0).
        -- 3. Else, set to NULL (rare due to WHERE rn = 1 and lifecycle check).
        CASE 
            WHEN sls_order_dt IS NOT NULL THEN sls_order_dt
            WHEN sls_ship_dt >= prd_start_date 
                 AND sls_ship_dt < prd_end_date 
            THEN sls_ship_dt
            ELSE NULL
        END AS sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_quantity,
        sls_price,
        sls_sales,
        ingested_at,
        updated_at
    FROM product_lifecycle
    WHERE rn = 1  
    -- Filters to only the top-ranked lifecycle row per sls_ord_num, sls_prd_key, ensuring we use the active lifecycle where sls_ship_dt fits, avoiding ambiguity from multiple matches.
),

calculated_sales AS (
    -- Purpose: Adjusts sales price and total sales values based on data quality rules, ensuring consistency 
    -- and accuracy in financial metrics.
    SELECT 
        *,
        -- Adjusts sls_price:
        -- If sls_price is NULL or negative, calculate it as sls_sales / sls_quantity (avoiding division by 0 
        -- with NULLIF). Otherwise, keep the original price. This corrects invalid or missing price data.
        CASE 
            WHEN sls_price IS NULL OR sls_price < 0 
            THEN sls_sales / NULLIF(sls_quantity, 0)
            ELSE sls_price 
        END AS adjusted_sls_price,
        -- Adjusts sls_sales:
        -- If sls_sales is NULL, negative, or inconsistent with quantity * price, recalculate as 
        -- sls_quantity * ABS(sls_price) to ensure positive, logical totals. Otherwise, keep the original.
        CASE 
            WHEN sls_sales IS NULL OR sls_sales < 0 OR sls_sales != sls_quantity * ABS(sls_price) 
            THEN sls_quantity * ABS(sls_price)
            ELSE sls_sales 
        END AS adjusted_sls_sales
    FROM cleaned_sales_dates
)

SELECT 
    -- Final output selects all cleaned and adjusted fields, renaming adjusted_sls_price and 
    -- adjusted_sls_sales to sls_price and sls_sales for downstream consistency.
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_quantity,
    adjusted_sls_price AS sls_price,
    adjusted_sls_sales AS sls_sales,
    ingested_at,
    updated_at
FROM calculated_sales

  );
  
  