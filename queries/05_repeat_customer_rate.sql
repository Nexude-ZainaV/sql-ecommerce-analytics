-- 05 Repeat vs one-time buyers.
-- Question: what share of buyers came back, and how much more do they spend?
-- Techniques: CTE + CASE bucketing, conditional aggregation.

-- Order count and total spend for everyone who bought at least once.
WITH buyer AS (
    SELECT customer_id, COUNT(*) AS orders, SUM(order_cents) AS cents
    FROM v_order_totals
    GROUP BY customer_id
)
-- Split buyers into repeat and one-time, then compare head count and average spend.
SELECT
    CASE WHEN orders > 1 THEN 'repeat' ELSE 'one-time' END   AS segment,
    COUNT(*)                                                  AS customers,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM buyer), 1) AS pct_of_buyers,
    ROUND(AVG(cents) / 100.0, 2)                              AS avg_lifetime_value
FROM buyer
GROUP BY segment
ORDER BY segment DESC;
