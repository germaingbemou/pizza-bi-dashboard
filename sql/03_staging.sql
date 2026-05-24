-- Rebuild stg.pizzas defensively
DROP TABLE IF EXISTS stg.pizzas;

SELECT
    LTRIM(RTRIM(REPLACE(REPLACE(pizza_id,      CHAR(13), ''), CHAR(10), '')))    AS pizza_id,
    LTRIM(RTRIM(REPLACE(REPLACE(pizza_type_id, CHAR(13), ''), CHAR(10), '')))    AS pizza_type_id,
    UPPER(LTRIM(RTRIM(REPLACE(REPLACE(size,    CHAR(13), ''), CHAR(10), ''))))   AS size_code,
    TRY_CAST(REPLACE(REPLACE(price, CHAR(13), ''), CHAR(10), '') AS DECIMAL(10,2)) AS unit_price
INTO stg.pizzas
FROM raw.pizzas
WHERE TRY_CAST(REPLACE(REPLACE(price, CHAR(13), ''), CHAR(10), '') AS DECIMAL(10,2)) IS NOT NULL;

-- Verify
SELECT COUNT(*) AS row_count FROM stg.pizzas;  -- Expected: 96
SELECT TOP 5 * FROM stg.pizzas;


-- Rebuild stg.pizza_types defensively
DROP TABLE IF EXISTS stg.pizza_types;

SELECT
    LTRIM(RTRIM(REPLACE(REPLACE(pizza_type_id, CHAR(13), ''), CHAR(10), '')))   AS pizza_type_id,
    LTRIM(RTRIM(REPLACE(REPLACE([name],        CHAR(13), ''), CHAR(10), '')))   AS pizza_name,
    LTRIM(RTRIM(REPLACE(REPLACE(category,      CHAR(13), ''), CHAR(10), '')))   AS category,
    LTRIM(RTRIM(REPLACE(REPLACE(ingredients,   CHAR(13), ''), CHAR(10), '')))   AS ingredients
INTO stg.pizza_types
FROM raw.pizza_types;

-- Verify
SELECT COUNT(*) AS row_count FROM stg.pizza_types;  -- Expected: 32
SELECT TOP 5 * FROM stg.pizza_types;


DROP TABLE IF EXISTS stg.order_details;

SELECT
    TRY_CAST(LTRIM(RTRIM(order_details_id)) AS INT)                            AS order_detail_id,
    TRY_CAST(LTRIM(RTRIM(order_id)) AS INT)                                    AS order_id,
    LTRIM(RTRIM(REPLACE(REPLACE(pizza_id, CHAR(13), ''), CHAR(10), '')))       AS pizza_id,
    TRY_CAST(REPLACE(REPLACE(quantity, CHAR(13), ''), CHAR(10), '') AS INT)    AS quantity
INTO stg.order_details
FROM raw.order_details
WHERE TRY_CAST(LTRIM(RTRIM(order_details_id)) AS INT) IS NOT NULL
  AND TRY_CAST(LTRIM(RTRIM(order_id)) AS INT) IS NOT NULL
  AND TRY_CAST(REPLACE(REPLACE(quantity, CHAR(13), ''), CHAR(10), '') AS INT) IS NOT NULL;

SELECT COUNT(*) FROM stg.order_details;  -- Expected: 48,620


-- Should now return 0
SELECT COUNT(*) AS orphan_order_lines
FROM stg.order_details od
LEFT JOIN stg.pizzas p ON od.pizza_id = p.pizza_id
WHERE p.pizza_id IS NULL;

SELECT COUNT(*) AS orphan_pizzas
FROM stg.pizzas p
LEFT JOIN stg.pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
WHERE pt.pizza_type_id IS NULL;




