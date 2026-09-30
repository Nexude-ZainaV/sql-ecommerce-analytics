-- 02 Month-over-month revenue growth.
-- Question: which months grew and which shrank, by how much?
-- Techniques: CTE, LAG() to read the previous row, NULLIF to avoid division by zero.

WITH monthly AS (
    SELECT order_month, SUM(order_cents) AS cents
    FROM v_order_totals
    GROUP BY order_month
)
SELECT
    order_month,
    ROUND(cents / 100.0, 2)                                   AS revenue,
    ROUND(LAG(cents) OVER (ORDER BY order_month) / 100.0, 2)  AS previous_revenue,
    ROUND(100.0 * (cents - LAG(cents) OVER (ORDER BY order_month))
          / NULLIF(LAG(cents) OVER (ORDER BY order_month), 0), 1) AS growth_pct
FROM monthly
ORDER BY order_month;
