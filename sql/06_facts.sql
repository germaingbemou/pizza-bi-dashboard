DROP TABLE IF EXISTS fact.fact_order_line;

SELECT
    od.order_detail_id                                    AS order_detail_id,  -- PK
    od.order_id                                           AS order_id,
    o.date_key                                            AS date_key,         -- FK to dim_date
    DATEPART(HOUR, o.order_time)                          AS hour_24,          -- FK to dim_time
    od.pizza_id                                           AS pizza_id,         -- FK to dim_pizza
    od.quantity                                           AS quantity,
    p.unit_price                                          AS unit_price,
    CAST(od.quantity * p.unit_price AS DECIMAL(10,2))     AS line_revenue
INTO fact.fact_order_line
FROM stg.order_details od
INNER JOIN stg.orders   o ON od.order_id  = o.order_id
INNER JOIN stg.pizzas   p ON od.pizza_id  = p.pizza_id;

-- Sanity check the revenue total
SELECT
    COUNT(*)                AS line_count,
    SUM(line_revenue)       AS total_revenue,
    SUM(quantity)           AS total_pizzas
FROM fact.fact_order_line;
-- Expected: 48,620 lines, ~$817,860 revenue



DROP TABLE IF EXISTS fact.fact_order;

;WITH order_rollup AS (
    SELECT
        fol.order_id,
        fol.date_key,
        MIN(fol.hour_24)                       AS order_hour,
        SUM(fol.quantity)                      AS total_pizzas,
        SUM(fol.line_revenue)                  AS order_revenue,
        COUNT(DISTINCT fol.pizza_id)           AS distinct_pizzas,
        COUNT(DISTINCT dp.category)            AS distinct_categories,
        COUNT(*)                               AS line_count
    FROM fact.fact_order_line fol
    INNER JOIN dim.dim_pizza dp ON fol.pizza_id = dp.pizza_id
    GROUP BY fol.order_id, fol.date_key
)
SELECT
    order_id,
    date_key,
    order_hour,
    total_pizzas,
    order_revenue,
    distinct_pizzas,
    distinct_categories,
    line_count,
    -- Useful derived field
    CAST(order_revenue / NULLIF(total_pizzas, 0) AS DECIMAL(10,2)) AS revenue_per_pizza
INTO fact.fact_order
FROM order_rollup;

-- Sanity check
SELECT
    COUNT(*)                  AS order_count,
    SUM(order_revenue)        AS total_revenue,
    AVG(order_revenue)        AS avg_ticket,
    AVG(total_pizzas * 1.0)   AS avg_pizzas_per_order
FROM fact.fact_order;
-- Expected: 21,350 orders, ~$817,860 revenue, ~$38.31 avg ticket

