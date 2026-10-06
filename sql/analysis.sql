-- ============================================================================
-- online-retail-customer-analytics — analytical queries
-- ============================================================================
-- Run from the repository root after loading the data:
--     psql -U postgres -d portfolio -f sql/analysis.sql
--
-- Conventions used throughout
--   * Transaction value of one line item = quantity * unitprice.
--   * "Cancelled" = invoiceno starting with 'C' (the credit-note prefix used
--     by this retailer). Cancellations are kept for the descriptive
--     aggregates (so figures match the raw data) but excluded from the
--     RFM and revenue-trend sections, where only completed sales matter.
--   * Recency is measured in days against the latest invoice in the data.
-- ============================================================================

-- ============================================================================
-- (1) RFM segmentation per customer
--     Recency  = days since the customer's last completed purchase,
--                measured against the max invoice date in the data.
--     Frequency = number of distinct completed invoices.
--     Monetary  = SUM(quantity * unitprice) over completed purchases.
--     Each dimension is split into quintiles with NTILE(5): 5 = best.
-- ============================================================================
WITH rfm_values AS (
    SELECT
        customerid,
        ((SELECT MAX(invoicedate) FROM online_retail)::date
            - MAX(invoicedate)::date)                                   AS recency_days,
        COUNT(DISTINCT invoiceno)                                        AS frequency,
        SUM(quantity * unitprice)                                        AS monetary
    FROM online_retail
    WHERE customerid IS NOT NULL
      AND invoiceno NOT LIKE 'C%'        -- completed sales only
      AND quantity > 0
    GROUP BY customerid
),
rfm_scored AS (
    SELECT
        customerid,
        recency_days,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY recency_days DESC)  AS r_score,  -- low recency = best
        NTILE(5) OVER (ORDER BY frequency)          AS f_score,
        NTILE(5) OVER (ORDER BY monetary)           AS m_score
    FROM rfm_values
),
rfm_segments AS (
    SELECT
        *,
        CASE
            WHEN r_score = 5 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
            WHEN r_score >= 4 AND f_score >= 4                  THEN 'Loyal Customers'
            WHEN r_score = 5 AND f_score = 1                    THEN 'New Customers'
            WHEN r_score >= 4 AND (f_score <= 3 OR m_score <= 3) THEN 'Potential Loyalists'
            WHEN r_score = 1 AND f_score >= 4 AND m_score >= 4  THEN 'Cannot Lose Them'
            WHEN r_score = 1 AND f_score <= 2 AND m_score <= 2  THEN 'Lost'
            WHEN r_score <= 2 AND f_score >= 3                  THEN 'At Risk'
            WHEN r_score <= 2 AND f_score <= 2                  THEN 'Hibernating'
            ELSE 'Need Attention'
        END AS segment
    FROM rfm_scored
)
SELECT
    segment,
    COUNT(*)                                   AS customers,
    ROUND(AVG(recency_days), 1)                AS avg_recency_days,
    ROUND(AVG(frequency), 1)                   AS avg_frequency,
    ROUND(AVG(monetary), 2)                    AS avg_monetary_gbp,
    ROUND(SUM(monetary), 2)                    AS total_monetary_gbp
FROM rfm_segments
GROUP BY segment
ORDER BY total_monetary_gbp DESC;

-- ============================================================================
-- (2) Monthly revenue trend (net revenue: cancelled invoices excluded)
-- ============================================================================
SELECT
    DATE_TRUNC('month', invoicedate)::date        AS month,
    COUNT(DISTINCT invoiceno)                     AS completed_invoices,
    ROUND(SUM(quantity * unitprice), 2)           AS net_revenue_gbp
FROM online_retail
WHERE invoiceno NOT LIKE 'C%'
GROUP BY 1
ORDER BY 1;

-- ============================================================================
-- (3) Top 10 products by revenue (full dataset, matches raw totals)
-- ============================================================================
SELECT
    stockcode,
    MAX(description)                             AS description,
    ROUND(SUM(quantity * unitprice), 2)          AS revenue_gbp,
    SUM(quantity)                                AS total_quantity
FROM online_retail
GROUP BY stockcode
ORDER BY revenue_gbp DESC
LIMIT 10;

-- ============================================================================
-- (4) Top countries by revenue (full dataset, matches raw totals)
-- ============================================================================
SELECT
    country,
    COUNT(*)                                     AS transactions,
    ROUND(SUM(quantity * unitprice), 2)          AS revenue_gbp,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2)
                                                 AS pct_of_transactions
FROM online_retail
GROUP BY country
ORDER BY revenue_gbp DESC
LIMIT 10;

-- ============================================================================
-- (5) Cohort retention: first-purchase-month cohorts, % of each cohort
--     active in each subsequent month (completed sales only).
-- ============================================================================
WITH customer_cohorts AS (
    SELECT
        customerid,
        DATE_TRUNC('month', MIN(invoicedate))::date AS cohort_month
    FROM online_retail
    WHERE customerid IS NOT NULL
      AND invoiceno NOT LIKE 'C%'
    GROUP BY customerid
),
monthly_activity AS (
    SELECT DISTINCT
        o.customerid,
        DATE_TRUNC('month', o.invoicedate)::date AS active_month
    FROM online_retail o
    WHERE o.customerid IS NOT NULL
      AND o.invoiceno NOT LIKE 'C%'
),
cohort_sizes AS (
    SELECT cohort_month, COUNT(*) AS cohort_size
    FROM customer_cohorts
    GROUP BY cohort_month
)
SELECT
    c.cohort_month,
    s.cohort_size,
    -- months since the cohort's first purchase month (0 = acquisition month)
    (EXTRACT(YEAR FROM a.active_month) - EXTRACT(YEAR FROM c.cohort_month)) * 12
      + (EXTRACT(MONTH FROM a.active_month) - EXTRACT(MONTH FROM c.cohort_month))
      AS month_offset,
    COUNT(DISTINCT a.customerid) AS active_customers,
    ROUND(COUNT(DISTINCT a.customerid) * 100.0 / s.cohort_size, 1)
        AS retention_pct
FROM customer_cohorts c
JOIN cohort_sizes s  ON s.cohort_month = c.cohort_month
JOIN monthly_activity a ON a.customerid = c.customerid
                      AND a.active_month >= c.cohort_month
GROUP BY c.cohort_month, s.cohort_size, month_offset
ORDER BY c.cohort_month, month_offset;

-- ============================================================================
-- Verification: key descriptive figures (full dataset, raw totals)
-- ============================================================================

-- Countries contributing more than 1% of transactions
WITH country_counts AS (
    SELECT country, COUNT(*) AS transactions
    FROM online_retail
    GROUP BY country
),
country_pcts AS (
    SELECT country,
           transactions,
           ROUND(transactions * 100.0 / SUM(transactions) OVER (), 2) AS pct_of_total
    FROM country_counts
)
SELECT country, transactions, pct_of_total
FROM country_pcts
WHERE pct_of_total > 1
ORDER BY pct_of_total DESC;

-- Most valuable customer (raw transaction value, missing CustomerID dropped)
SELECT customerid,
       ROUND(SUM(quantity * unitprice), 2) AS total_value_gbp
FROM online_retail
WHERE customerid IS NOT NULL
GROUP BY customerid
ORDER BY total_value_gbp DESC
LIMIT 1;

-- France return rate: cancelled / total transactions
SELECT COUNT(*)                                             AS fr_transactions,
       COUNT(*) FILTER (WHERE invoiceno LIKE 'C%')           AS fr_cancelled,
       ROUND(COUNT(*) FILTER (WHERE invoiceno LIKE 'C%') * 100.0
             / COUNT(*), 2)                                  AS return_rate_pct
FROM online_retail
WHERE country = 'France';

-- Transactions by weekday and by month (raw counts)
SELECT TO_CHAR(invoicedate, 'Day') AS weekday,
       EXTRACT(DOW FROM invoicedate) AS dow,
       COUNT(*) AS transactions
FROM online_retail
GROUP BY 1, 2
ORDER BY transactions DESC;

SELECT EXTRACT(MONTH FROM invoicedate)::int AS month,
       COUNT(*) AS transactions
FROM online_retail
GROUP BY 1
ORDER BY transactions DESC;
