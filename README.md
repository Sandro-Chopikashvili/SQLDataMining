# 📊 SQL Homework Project

Welcome to my **SQL Homework Project**! This repository contains 20 different SQL queries designed to practice and showcase various SQL skills like joins, aggregations, window functions, CTEs, and more — all based on a sample e-commerce database.  

---

## 🗂️ Project Structure

- `customers` — Customer details like ID, full name, country, etc.
- `products` — Product info including category, price, and stock.
- `orders` — Orders placed by customers with total amounts and dates.
- `order_items` — Line items for each order with quantity and price.
- `reviews` — Product reviews with ratings by customers.

---

## 🚀 What You’ll Find Here

The SQL queries cover:

- Counting orders and customers  
- Calculating revenue by category and month  
- Ranking customers by spending  
- Listing products never ordered  
- Finding top-selling products and categories  
- Working with window functions and regex  
- And much more!

---

## 📝 Sample Queries

Here are a couple of examples from the project:

### 1. Top 5 Customers by Number of Orders

```sql
SELECT c.full_name, COUNT(*) AS order_count
FROM customers c
JOIN orders o USING(customer_id)
GROUP BY c.full_name
ORDER BY order_count DESC
LIMIT 5;

