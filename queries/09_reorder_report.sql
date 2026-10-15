-- 09 Reorder report: low stock ranked by recent sales velocity.
-- Question: what should purchasing reorder first, as of the end of the period?
-- Techniques: a parameter CTE (one place to change the report date), date() modifiers,
-- LEFT JOIN + COALESCE for items with no recent sales, CASE for urgency.

-- Report date and look-back window, kept in one place.
WITH params AS (
    SELECT '2026-06-30' AS as_of, 90 AS window_days
),
-- Units sold per product in the window before the report date.
recent_sales AS (
    SELECT s.product_id, SUM(s.quantity) AS units
    FROM v_sales_lines s, params
    WHERE s.ordered_at > date(params.as_of, '-' || params.window_days || ' days')
      AND s.ordered_at <= params.as_of
    GROUP BY s.product_id
)
-- Products at or below their reorder level: out of stock first, then the fastest sellers.
SELECT
    p.sku,
    p.name,
    p.stock_qty,
    p.reorder_level,
    COALESCE(r.units, 0)                                     AS units_sold_90d,
    CASE
        WHEN p.stock_qty = 0 THEN 'out of stock'
        WHEN p.stock_qty < p.reorder_level THEN 'below reorder level'
        ELSE 'at reorder level'
    END                                                      AS urgency
FROM products p
LEFT JOIN recent_sales r ON r.product_id = p.id
WHERE p.stock_qty <= p.reorder_level
ORDER BY p.stock_qty = 0 DESC, units_sold_90d DESC, p.sku;
