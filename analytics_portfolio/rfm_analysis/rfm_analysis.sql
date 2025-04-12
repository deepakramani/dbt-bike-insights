WITH
    rfm_metrics AS (
        SELECT
            fs.customer_key,
            DATEDIFF ('day', MAX(fs.sales_order_date), '2014-02-01') AS recency_days, -- Days since last purchase
            COUNT(DISTINCT fs.sales_order_number) AS frequency,
            SUM(fs.sales_amount) AS monetary
        FROM
            "dwh"."gold"."fact_sales" fs
        WHERE
            fs.sales_order_date IS NOT NULL
        GROUP BY
            fs.customer_key
    ),
    rfm_scores AS (
        SELECT
            customer_key,
            recency_days,
            frequency,
            monetary,
            NTILE (5) OVER (
                ORDER BY
                    recency_days
            ) AS r_score, -- 1 = most recent, 5 = least recent
            NTILE (5) OVER (
                ORDER BY
                    frequency DESC
            ) AS f_score, -- 5 = most frequent
            NTILE (5) OVER (
                ORDER BY
                    monetary DESC
            ) AS m_score -- 5 = highest spend
        FROM
            rfm_metrics
    )
SELECT
    customer_key,
    recency_days,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    CONCAT (r_score, '-', f_score, '-', m_score) AS rfm_segment
FROM
    rfm_scores
ORDER BY
    m_score DESC,
    f_score DESC,
    r_score ASC;
