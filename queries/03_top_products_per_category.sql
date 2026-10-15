-- 03 Top 2 products by revenue in each category.
-- Question: what are the best sellers per category?
-- Techniques: "top N per group" with ROW_NUMBER() OVER (PARTITION BY ...).

-- Units sold and revenue for each product, labelled with its category.
WITH product_revenue AS (
    SELECT
        c.name                  AS category,
        p.name                  AS product,
        SUM(s.quantity)         AS units,
        SUM(s.line_cents)       AS cents
    FROM v_sales_lines s
    JOIN products p   ON p.id = s.product_id
    JOIN categories c ON c.id = s.category_id
    GROUP BY c.name, p.name
),
-- Each product's position inside its category (ties go to the name, alphabetically).
ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY category ORDER BY cents DESC, product) AS rank_in_category
    FROM product_revenue
)
-- Keep the best two per category.
SELECT category, rank_in_category, product, units, ROUND(cents / 100.0, 2) AS revenue
FROM ranked
WHERE rank_in_category <= 2
ORDER BY category, rank_in_category;
