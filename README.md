# DataWareHouse_DataAnalysis_using_SQL

This project focuses on comprehensive data analysis of an E-commerce database using SQL. The analysis aims to understand customer behavior, product performance, and overall business trends to inform strategic decision-making.

---

## 📂 Project Structure

- **`Database Exploration.sql`**  
  Basic schema inspection using the `INFORMATION_SCHEMA` to understand database structure and metadata.

- **`data project 2.sql`**  
  Foundational exploration including:
  - Country distribution of customers
  - Product categories and subcategories
  - Date range of orders
  - Customer age demographics
  - Basic sales metrics (total sales, quantity, average price)

- **`data project part 3.sql`**  
  Trend analysis over time:
  - Monthly/yearly sales trends
  - Customer count and product quantity over time
  - Running total of sales and moving average prices
  - Product performance benchmarking

- **`data project part 4.sql`**  
  Deep dive into:
  - Sales contribution by category
  - Product segmentation by cost range
  - Customer segmentation based on spending behavior

---

## 🧰 Tools & Technologies

- **SQL Server / T-SQL**
- **Data Warehousing Concepts**
- Tables used follow a star schema:  
  `dim_customers`, `dim_products`, `fact_sales`, etc.

---

## 📊 Key Insights

- High-performing product categories and cost brackets
- Customer demographics and segmentation
- Seasonal trends in sales performance
- Cumulative performance tracking and benchmarks

---

## 🚀 How to Use

1. Clone this repository.
2. Load the `.sql` files into your SQL Server Management Studio or compatible SQL environment.
3. Ensure access to the appropriate database schema (e.g., `gold.dim_customers`, `gold.fact_sales`).
4. Execute scripts in order, or explore them individually based on your needs.

---

## 📌 Notes

- All queries are written in T-SQL and optimized for SQL Server environments.
- Comments within SQL scripts guide the logic and purpose of each section.
