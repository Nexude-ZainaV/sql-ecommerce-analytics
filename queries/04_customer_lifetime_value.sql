-- 04 Customer lifetime value (CLV) ranking.
-- Question: who are our most valuable customers, and what share of revenue is theirs?
-- Techniques: LEFT JOIN to keep customers with no orders, COALESCE, DENSE_RANK(),
-- a window SUM() over the whole result for percent-of-total.

-- Order count and total spend per customer, including customers who never ordered.
WITH per_customer AS (
    SELECT
        c.id,
        c.full_name,
        c.country,
        COUNT(t.order_id)             AS orders,
        COALESCE(SUM(t.order_cents), 0) AS cents
    FROM customers c
    LEFT JOIN v_order_totals t ON t.customer_id = c.id
    GROUP BY c.id, c.full_name, c.country
)
-- Rank customers by spend and show each one's share of all revenue.
SELECT
    DENSE_RANK() OVER (ORDER BY cents DESC)          AS clv_rank,
    full_name,
    country,
    orders,
    ROUND(cents / 100.0, 2)                          AS lifetime_value,
    ROUND(100.0 * cents / SUM(cents) OVER (), 1)     AS pct_of_revenue
FROM per_customer
ORDER BY clv_rank, full_name;
