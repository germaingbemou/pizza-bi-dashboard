DROP TABLE IF EXISTS dim.dim_pizza;

SELECT
    p.pizza_id                         AS pizza_id,           -- natural key
    p.pizza_type_id                    AS pizza_type_id,
    pt.pizza_name                      AS pizza_name,
    pt.category                        AS category,
    p.size_code                        AS size_code,
    -- Ordered size for sorting in Tableau
    CASE p.size_code
        WHEN 'S'   THEN 1
        WHEN 'M'   THEN 2
        WHEN 'L'   THEN 3
        WHEN 'XL'  THEN 4
        WHEN 'XXL' THEN 5
    END                                AS size_order,
    CASE p.size_code
        WHEN 'S'   THEN 'Small'
        WHEN 'M'   THEN 'Medium'
        WHEN 'L'   THEN 'Large'
        WHEN 'XL'  THEN 'X-Large'
        WHEN 'XXL' THEN 'XX-Large'
    END                                AS size_label,
    p.unit_price                       AS unit_price,
    pt.ingredients                     AS ingredients
INTO dim.dim_pizza
FROM stg.pizzas p
INNER JOIN stg.pizza_types pt ON p.pizza_type_id = pt.pizza_type_id;

-- Quick check
SELECT COUNT(*) FROM dim.dim_pizza;  -- Expected: 96



DROP TABLE IF EXISTS dim.dim_date;

;WITH date_range AS (
    SELECT CAST('2015-01-01' AS DATE) AS d
    UNION ALL
    SELECT DATEADD(DAY, 1, d)
    FROM date_range
    WHERE d < '2015-12-31'
)
SELECT
    d                                                     AS date_key,
    YEAR(d)                                               AS year,
    DATEPART(QUARTER, d)                                  AS quarter,
    'Q' + CAST(DATEPART(QUARTER, d) AS VARCHAR(1))        AS quarter_label,
    MONTH(d)                                              AS month_num,
    DATENAME(MONTH, d)                                    AS month_name,
    LEFT(DATENAME(MONTH, d), 3)                           AS month_short,
    DATEPART(WEEK, d)                                     AS week_of_year,
    DATEPART(WEEKDAY, d)                                  AS day_of_week_num,
    DATENAME(WEEKDAY, d)                                  AS day_name,
    LEFT(DATENAME(WEEKDAY, d), 3)                         AS day_short,
    CASE WHEN DATEPART(WEEKDAY, d) IN (1, 7)
         THEN 1 ELSE 0 END                                AS is_weekend,
    CASE
        WHEN MONTH(d) IN (12, 1, 2) THEN 'Winter'
        WHEN MONTH(d) IN (3, 4, 5)  THEN 'Spring'
        WHEN MONTH(d) IN (6, 7, 8)  THEN 'Summer'
        ELSE 'Fall'
    END                                                   AS season
INTO dim.dim_date
FROM date_range
OPTION (MAXRECURSION 400);

-- Verify: 365 rows for 2015
SELECT COUNT(*) FROM dim.dim_date;


DROP TABLE IF EXISTS dim.dim_time;

;WITH hours AS (
    SELECT 0 AS h
    UNION ALL
    SELECT h + 1 FROM hours WHERE h < 23
)
SELECT
    h                                                     AS hour_24,
    CASE
        WHEN h = 0  THEN '12 AM'
        WHEN h < 12 THEN CAST(h AS VARCHAR) + ' AM'
        WHEN h = 12 THEN '12 PM'
        ELSE CAST(h - 12 AS VARCHAR) + ' PM'
    END                                                   AS hour_label,
    CASE
        WHEN h BETWEEN 11 AND 14 THEN 'Lunch Rush'
        WHEN h BETWEEN 17 AND 20 THEN 'Dinner Rush'
        WHEN h BETWEEN 15 AND 16 THEN 'Afternoon Lull'
        WHEN h BETWEEN 21 AND 23 THEN 'Late Night'
        ELSE 'Off-Hours'
    END                                                   AS daypart
INTO dim.dim_time
FROM hours;


