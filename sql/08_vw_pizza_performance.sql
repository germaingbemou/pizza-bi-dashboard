DROP VIEW IF EXISTS mart.vw_pizza_performance;
GO

CREATE VIEW mart.vw_pizza_performance AS
SELECT
    dp.pizza_id                                                    AS pizza_id,
    dp.pizza_name                                                  AS pizza_name,
    dp.category                                                    AS category,
    dp.size_code                                                   AS size_code,
    dp.size_label                                                  AS size_label,
    dp.size_order                                                  AS size_order,
    dp.unit_price                                                  AS unit_price,
    dp.ingredients                                                 AS ingredients,
    SUM(fol.quantity)                                              AS pizzas_sold,
    COUNT(DISTINCT fol.order_id)                                   AS orders_with_pizza,
    SUM(fol.line_revenue)                                          AS revenue,
    SUM(fol.line_revenue) * 100.0 /
        SUM(SUM(fol.line_revenue)) OVER ()                         AS pct_of_total_revenue,
    RANK() OVER (
        ORDER BY SUM(fol.line_revenue) DESC
    )                                                              AS revenue_rank,
    RANK() OVER (
        PARTITION BY dp.category
        ORDER BY SUM(fol.line_revenue) DESC
    )                                                              AS rank_within_category,
    SUM(fol.line_revenue) * 1.0 /
        NULLIF(COUNT(DISTINCT fol.order_id), 0)                    AS revenue_per_order,
    CASE
        WHEN RANK() OVER (ORDER BY SUM(fol.line_revenue) DESC) <= 5                              THEN 'Top 5'
        WHEN RANK() OVER (ORDER BY SUM(fol.line_revenue) DESC) > (COUNT(*) OVER () - 5)          THEN 'Bottom 5'
        ELSE 'Middle'
    END                                                            AS performance_tier
FROM fact.fact_order_line fol
INNER JOIN dim.dim_pizza dp ON fol.pizza_id = dp.pizza_id
GROUP BY dp.pizza_id, dp.pizza_name, dp.category, dp.size_code,
         dp.size_label, dp.size_order, dp.unit_price, dp.ingredients;
GO


SELECT performance_tier, COUNT(*) AS pizza_count
FROM mart.vw_pizza_performance
GROUP BY performance_tier;
-- Expected: Top 5 = 5, Bottom 5 = 5, Middle = 81

-- Export to Excel and add to your Tableau workbook