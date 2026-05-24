-- Are all pizza_ids in order_details present in pizzas?
SELECT COUNT(*) AS orphan_order_lines
FROM stg.order_details od
LEFT JOIN stg.pizzas p ON od.pizza_id = p.pizza_id
WHERE p.pizza_id IS NULL;
-- Expected: 0

-- Are all pizza_type_ids in pizzas present in pizza_types?
SELECT COUNT(*) AS orphan_pizzas
FROM stg.pizzas p
LEFT JOIN stg.pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
WHERE pt.pizza_type_id IS NULL;
-- Expected: 0

-- Are all order_ids in order_details present in orders?
SELECT COUNT(*) AS orphan_details
FROM stg.order_details od
LEFT JOIN stg.orders o ON od.order_id = o.order_id
WHERE o.order_id IS NULL;
-- Expected: 0


