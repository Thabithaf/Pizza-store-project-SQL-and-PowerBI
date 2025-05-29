-- Retrieve the total number of orders placed.
SELECT count(order_id) as total_orders FROM orders;

-- Calculate the total revenue generated from pizza sales.
SELECT round(sum(order_details.quantity * pizzas.price),2) as total_revenue
FROM order_details join pizzas
on pizzas.pizza_id = order_details.pizza_id;

-- Identify the highest-priced pizza.
SELECT pizza_types.name, pizzas.price
FROM pizzas join pizza_types
on pizzas.pizza_type_id = pizza_types.pizza_type_id
order by price desc limit 1;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT pizza_types.name,
sum(order_details.quantity) as quantity 
FROM pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name order by quantity desc limit 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT pizza_types.category,
sum(order_details.quantity) as Total_quantity
FROM pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on
order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category order by Total_quantity desc;

-- Determine the distribution of orders by hour of the day.
select hour(time) as Hours, count(order_id) as Count_of_ID
from orders
group by hour(time) limit 10;

-- Group the orders by date and calculate the average number of pizzas
-- ordered per day
SELECT AVG(quantity) AS Average_quantity
FROM (
    SELECT orders.date, SUM(order_details.quantity) AS quantity
    FROM orders
    JOIN order_details
    ON orders.order_id = order_details.order_id
    GROUP BY orders.date
) AS Orders;

-- Calculate the percentage contribution of each pizza type to total revenue.
select pizza_types.category,
round(sum(order_details.quantity * pizzas.price)/(select
	round(sum(order_details.quantity *pizzas.price), 
			2) as Total_sales
from
	order_details
			join
	pizzas on pizzas.pizza_id = order_details.pizza_id) * 100, 2) as Revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id =pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category order by Revenue desc;

-- Calculate the average quantity of pizzas per order for each pizza type to understand which 
-- pizzas are ordered in bulk.
SELECT 
    pt.name,
    AVG(od.quantity) AS avg_quantity_per_order
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY avg_quantity_per_order DESC
Limit 5;

-- Analyze which days of the week have the highest order volumes to optimize staffing.
SELECT 
    DAYNAME(o.date) AS day_of_week,
    COUNT(o.order_id) AS order_count,
    SUM(od.quantity) AS total_pizzas_sold
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
GROUP BY DAYNAME(o.date)
ORDER BY order_count DESC;

-- Estimate ingredient usage based on pizza types ordered to optimize inventory.
SELECT 
    pt.name,
    pt.ingredients,
    SUM(od.quantity) AS total_ordered
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.name, pt.ingredients
ORDER BY total_ordered DESC
LIMIT 5;

-- Analyze how much revenue comes from different pizza sizes (e.g., Small, Medium, Large).
SELECT 
    p.size,
    ROUND(SUM(od.quantity * p.price), 2) AS revenue_by_size
FROM pizzas p
JOIN order_details od ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY revenue_by_size DESC;

-- Analyze revenue by month to detect seasonal patterns.
SELECT 
    MONTHNAME(o.date) AS month,
    ROUND(SUM(od.quantity * p.price), 2) AS monthly_revenue
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY MONTHNAME(o.date), MONTH(o.date)
ORDER BY MONTH(o.date);

-- Identify which pizzas are commonly ordered together in the same order.
SELECT 
    pt1.name AS pizza_1,
    pt2.name AS pizza_2,
    COUNT(DISTINCT od1.order_id) AS times_ordered_together
FROM order_details od1
JOIN order_details od2 ON od1.order_id = od2.order_id AND od1.pizza_id < od2.pizza_id
JOIN pizzas p1 ON od1.pizza_id = p1.pizza_id
JOIN pizzas p2 ON od2.pizza_id = p2.pizza_id
JOIN pizza_types pt1 ON p1.pizza_type_id = pt1.pizza_type_id
JOIN pizza_types pt2 ON p2.pizza_type_id = pt2.pizza_type_id
GROUP BY pt1.name, pt2.name
ORDER BY times_ordered_together DESC
LIMIT 5;
