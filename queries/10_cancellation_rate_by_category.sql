-- 10 Order status mix and cancellation rate per category.
-- Question: are cancellations concentrated in one category?
-- Techniques: conditional aggregation (SUM(CASE ...)) to pivot statuses into columns,
-- reading raw tables (not the paid-only view) because cancelled orders matter here.

SELECT
    c.name                                                           AS category,
    COUNT(DISTINCT o.id)                                             AS orders,
    COUNT(DISTINCT CASE WHEN o.status IN ('paid', 'shipped', 'delivered') THEN o.id END) AS paid,
    COUNT(DISTINCT CASE WHEN o.status = 'pending' THEN o.id END)     AS pending,
    COUNT(DISTINCT CASE WHEN o.status = 'cancelled' THEN o.id END)   AS cancelled,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN o.status = 'cancelled' THEN o.id END)
          / COUNT(DISTINCT o.id), 1)                                 AS cancellation_pct
FROM orders o
JOIN order_items oi ON oi.order_id = o.id
JOIN products p     ON p.id = oi.product_id
JOIN categories c   ON c.id = p.category_id
GROUP BY c.name
ORDER BY cancellation_pct DESC, category;
