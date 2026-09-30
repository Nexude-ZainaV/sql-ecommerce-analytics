-- 01 Monthly revenue with a running total.
-- Question: how much did we sell each month, and how much year to date?
-- Techniques: GROUP BY on a derived month, window SUM() OVER (ORDER BY ...).

SELECT
    order_month,
    COUNT(*)                                         AS orders,
    ROUND(SUM(order_cents) / 100.0, 2)               AS revenue,
    ROUND(SUM(SUM(order_cents)) OVER (ORDER BY order_month) / 100.0, 2) AS revenue_ytd
FROM v_order_totals
GROUP BY order_month
ORDER BY order_month;
