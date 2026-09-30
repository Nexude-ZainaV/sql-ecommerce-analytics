-- 03_views.sql - reusable building blocks for the reports.

-- Revenue only counts orders that were paid for: paid, shipped or delivered.
-- Pending (not yet paid) and cancelled orders are excluded everywhere.
CREATE VIEW v_sales_lines AS
SELECT
    o.id                                AS order_id,
    o.customer_id,
    o.ordered_at,
    strftime('%Y-%m', o.ordered_at)     AS order_month,
    oi.product_id,
    p.category_id,
    oi.quantity,
    oi.quantity * oi.unit_price_cents   AS line_cents
FROM orders o
JOIN order_items oi ON oi.order_id = o.id
JOIN products p     ON p.id = oi.product_id
WHERE o.status IN ('paid', 'shipped', 'delivered');

-- One row per paid order with its total.
CREATE VIEW v_order_totals AS
SELECT
    order_id,
    customer_id,
    ordered_at,
    order_month,
    SUM(line_cents) AS order_cents,
    SUM(quantity)   AS units
FROM v_sales_lines
GROUP BY order_id, customer_id, ordered_at, order_month;
