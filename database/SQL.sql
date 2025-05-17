-- 1. Top 5 Customers by Number of Orders
SELECT c.full_name, COUNT(*) AS order_count
FROM customers c
JOIN orders o USING(customer_id)
GROUP BY c.full_name
ORDER BY order_count DESC
LIMIT 5;


-- 2. List Products Never Ordered
SELECT p.product_id, p.name, p.category, p.price, p.stock_quantity
FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.product_id
WHERE oi.product_id IS NULL;


-- 3. Top 3 Best-Selling Products by Quantity
WITH total_sales AS (
    SELECT product_id, SUM(quantity) AS total_sold
    FROM order_items
    GROUP BY product_id
)
SELECT p.name, ts.total_sold
FROM total_sales ts
JOIN products p USING(product_id)
ORDER BY ts.total_sold DESC
LIMIT 3;


-- 4. Revenue by Category
SELECT p.category, SUM(ot.quantity * ot.unit_price) AS revenue
FROM products p
JOIN order_items ot ON ot.product_id = p.product_id
GROUP BY p.category
ORDER BY revenue DESC;


-- 5. Monthly Revenue (Last 12 Months)
SELECT 
    DATE_TRUNC('month', order_date) AS month,
    SUM(total_amount) AS monthly_revenue
FROM orders
WHERE order_date >= CURRENT_DATE - INTERVAL '12 months'
GROUP BY month
ORDER BY month;


-- 6. Repeat Customers (More Than 1 Order)
SELECT
    c.customer_id,
    c.full_name,
    COUNT(o.order_id) AS order_count
FROM customers c
LEFT JOIN orders o USING(customer_id)
GROUP BY c.customer_id, c.full_name
HAVING COUNT(o.order_id) > 1
ORDER BY order_count DESC;


-- 7. Top 3 Categories by Revenue
SELECT
    p.category,
    SUM(ot.quantity * ot.unit_price) AS total_revenue
FROM products p
JOIN order_items ot ON p.product_id = ot.product_id
GROUP BY p.category
ORDER BY total_revenue DESC
LIMIT 3;


-- 8. Average Rating per Product
SELECT 
    p.name,
    ROUND(AVG(r.rating), 0) AS average_rating
FROM reviews r 
JOIN products p USING(product_id)
GROUP BY p.name;


-- 9. Top 5 Customers by Total Revenue
WITH customer_spending AS (
    SELECT
        c.full_name,
        SUM(o.total_amount) AS total_revenue
    FROM customers c
    JOIN orders o USING(customer_id)
    GROUP BY c.customer_id, c.full_name
)
SELECT
    full_name,
    total_revenue,
    RANK() OVER (ORDER BY total_revenue DESC) AS rank
FROM customer_spending
ORDER BY rank
LIMIT 5;


-- 10. Complete Order Details with Line Numbers
WITH header AS (
    SELECT
        o.order_id,
        c.full_name AS customer,
        o.order_date
    FROM orders o
    JOIN customers c ON c.customer_id = o.customer_id
),
lines AS (
    SELECT
        oi.order_id,
        ROW_NUMBER() OVER (PARTITION BY oi.order_id ORDER BY oi.order_item_id) AS line_no,
        p.name AS product,
        oi.quantity AS qty,
        oi.unit_price,
        oi.quantity * oi.unit_price AS line_total
    FROM order_items oi
    JOIN products p ON p.product_id = oi.product_id
)
SELECT
    h.order_id,
    h.customer,
    h.order_date,
    l.line_no,
    l.product,
    l.qty,
    l.unit_price,
    l.line_total
FROM header h
JOIN lines l USING (order_id)
ORDER BY h.order_id, l.line_no;


-- 11. Products with Repeated Initial Letters (Regex)
SELECT * 
FROM products
WHERE name ~ '^(?:\\w+\\s)?([A-Za-z])\\w*\\s\\1\\w*$';


-- 12. Customer Count by Country
SELECT country, COUNT(customer_id) AS customer_count
FROM customers
GROUP BY country
ORDER BY customer_count DESC;


-- 13. Most Recent Orders per Customer
SELECT DISTINCT ON (customer_id)
    customer_id,
    order_id,
    order_date,
    total_amount
FROM orders
ORDER BY customer_id, order_date DESC;


-- 14. Product Revenue by Category (Fixed with Unit Prices)
SELECT category, SUM(ot.quantity * ot.unit_price) AS revenue
FROM products p
JOIN order_items ot USING(product_id)
GROUP BY category
ORDER BY revenue DESC;


-- 15. Top 5 Countries by Number of Customers
SELECT country, COUNT(*) AS customer_count
FROM customers
GROUP BY country
ORDER BY customer_count DESC
LIMIT 5;


-- 16. Products with Stock Lower Than Demand
SELECT *
FROM products p
WHERE p.stock_quantity < (
    SELECT COALESCE(SUM(quantity), 0)
    FROM order_items oi
    WHERE oi.product_id = p.product_id
);


-- 17. 30-Day Rolling Revenue Window per Order
SELECT
    o.order_id,
    o.order_date,
    o.total_amount,
    SUM(o.total_amount) OVER (
        ORDER BY o.order_date
        RANGE BETWEEN INTERVAL '29 days' PRECEDING AND CURRENT ROW
    ) AS rolling_30_day_revenue
FROM orders o;


-- 18. Total Revenue + Ranking per Customer
WITH customer_spending AS (
    SELECT
        c.customer_id,
        c.full_name,
        SUM(o.total_amount) AS total_revenue
    FROM customers c
    JOIN orders o USING(customer_id)
    GROUP BY c.customer_id, c.full_name
)
SELECT
    full_name,
    total_revenue,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM customer_spending
ORDER BY revenue_rank;


-- 19. Total Orders and Revenue per Customer
SELECT
    c.full_name,
    COUNT(o.order_id) AS order_count,
    SUM(o.total_amount) AS total_spent
FROM customers c
JOIN orders o USING(customer_id)
GROUP BY c.full_name
ORDER BY total_spent DESC;


-- 20. Most Purchased Product Per Category
WITH category_sales AS (
    SELECT
        p.category,
        p.name,
        SUM(oi.quantity) AS total_sold,
        RANK() OVER (PARTITION BY p.category ORDER BY SUM(oi.quantity) DESC) AS rnk
    FROM products p
    JOIN order_items oi USING(product_id)
    GROUP BY p.category, p.name
)
SELECT category, name AS top_product, total_sold
FROM category_sales
WHERE rnk = 1;
