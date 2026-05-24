-- Raw landing tables (mirror source files exactly, all VARCHAR for safety)
CREATE TABLE raw.orders (
    order_id    VARCHAR(20),
    [date]      VARCHAR(20),
    [time]      VARCHAR(20)
);

CREATE TABLE raw.order_details (
    order_details_id VARCHAR(20),
    order_id         VARCHAR(20),
    pizza_id         VARCHAR(50),
    quantity         VARCHAR(10)
);

CREATE TABLE raw.pizzas (
    pizza_id      VARCHAR(50),
    pizza_type_id VARCHAR(50),
    size          VARCHAR(10),
    price         VARCHAR(20)
);

CREATE TABLE raw.pizza_types (
    pizza_type_id VARCHAR(50),
    [name]        VARCHAR(100),
    category      VARCHAR(50),
    ingredients   VARCHAR(500)
);