-- 07 Each customer's average order value (AOV) against the store average.
-- Question: who spends more per order than typical?
-- Techniques: window AVG() OVER () next to per-group aggregates, HAVING.

WITH customer_aov AS (
    SELECT customer_id, COUNT(*) AS orders, AVG(order_cents) AS aov_cents
    FROM v_order_totals
    GROUP BY customer_id
    HAVING COUNT(*) >= 2          -- one order is not a pattern
)
SELECT
    c.full_name,
    a.orders,
    ROUND(a.aov_cents / 100.0, 2)                                  AS avg_order_value,
    ROUND((SELECT AVG(order_cents) FROM v_order_totals) / 100.0, 2) AS store_avg_order_value,
    ROUND(100.0 * (a.aov_cents / (SELECT AVG(order_cents) FROM v_order_totals) - 1), 1)
                                                                   AS pct_vs_store
FROM customer_aov a
JOIN customers c ON c.id = a.customer_id
ORDER BY a.aov_cents DESC;
