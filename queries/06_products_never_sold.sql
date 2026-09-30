-- 06 Products that have never been sold.
-- Question: which catalogue items are dead stock?
-- Techniques: anti-join with NOT EXISTS (index-friendly, NULL-safe unlike NOT IN).

SELECT p.sku, p.name, c.name AS category, p.stock_qty
FROM products p
JOIN categories c ON c.id = p.category_id
WHERE NOT EXISTS (
    SELECT 1 FROM v_sales_lines s WHERE s.product_id = p.id
)
ORDER BY p.sku;
