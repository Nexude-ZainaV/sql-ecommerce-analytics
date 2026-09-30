-- 08 Cohort retention by first-purchase month.
-- Question: of the customers who first bought in month M, how many bought again
-- 1, 2 and 3+ months later?
-- Techniques: MIN() OVER (PARTITION BY ...) for the cohort, month arithmetic,
-- COUNT(DISTINCT CASE ...) pivot.

WITH purchases AS (
    SELECT
        customer_id,
        order_month,
        MIN(order_month) OVER (PARTITION BY customer_id) AS cohort
    FROM v_order_totals
),
aged AS (
    SELECT
        customer_id,
        cohort,
        -- months between two 'YYYY-MM' strings
        (CAST(substr(order_month, 1, 4) AS INTEGER) * 12 + CAST(substr(order_month, 6, 2) AS INTEGER))
      - (CAST(substr(cohort, 1, 4) AS INTEGER) * 12 + CAST(substr(cohort, 6, 2) AS INTEGER)) AS month_offset
    FROM purchases
)
SELECT
    cohort,
    COUNT(DISTINCT customer_id)                                        AS cohort_size,
    COUNT(DISTINCT CASE WHEN month_offset = 1 THEN customer_id END)    AS month_1,
    COUNT(DISTINCT CASE WHEN month_offset = 2 THEN customer_id END)    AS month_2,
    COUNT(DISTINCT CASE WHEN month_offset >= 3 THEN customer_id END)   AS month_3_plus
FROM aged
GROUP BY cohort
ORDER BY cohort;
