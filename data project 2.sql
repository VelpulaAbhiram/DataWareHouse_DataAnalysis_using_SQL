--Explore All Countries our customers come from.
SELECT DISTINCT country FROM gold.dim_customers

--Explore All Categories our "the major Divisions".
SELECT DISTINCT category,subcategory,product_name FROM gold.dim_products
order by 1,2,3

--Data Exploration

-- Find the date of the first and last order
SELECT min(order_date) as first_order_date,
max(order_date) as last_order_date,
DATEDIFF(month,min(order_date),max(order_date)) as order_range_years
From gold.fact_sales

--find youngest and oldest customer

select 
min(birthdate) as oldest_birthdate,
datediff (year,min(birthdate),getdate()) as oldest_age,
max(birthdate)as youngest_birthdate,
datediff (year,max(birthdate),getdate()) as youngest_age
from gold.dim_customers


--Measures Exploration
--total sales
select sum(sales_amount) as total_sales from gold.fact_sales
--find how many items are sold
select sum(quantity) as total_quantity from gold.fact_sales
--find the average selling price
select avg(price) as avg_price from gold.fact_sales
--find total no.of orders
select COUNT(order_number) as total_Orders from gold.fact_sales
select COUNT(distinct order_number) as total_Orders from gold.fact_sales

--find total no.of products
select COUNT(product_key)as total_products from gold.dim_products
select COUNT(distinct product_key)as total_products from gold.dim_products
--find total no.of customers
select COUNT(customer_key)as total_customers from gold.dim_customers
-- find the total no. of customers that has placed an orders
select COUNT(distinct customer_key)as total_customers from gold.dim_customers



--A Report that shows all key metrics of the business


select 'Total sales'as measure_name, sum(sales_amount) as measure_name  from gold.fact_sales
union all
select 'Total Quantity', sum(quantity)  from gold.fact_sales
union all
select 'Average price',avg(price) from gold.fact_sales
union all
select 'total no.of orders', COUNT(distinct order_number) from gold.fact_sales
union all
select 'total no.of products', COUNT(product_key) from gold.dim_products
union all
select 'total no.of orders', COUNT(customer_key) from gold.dim_customers



--Magnitude Analysis

--Find total customers by countries
select country,
count(customer_key) as total_customers
from gold.dim_customers
 GROUP BY country
 order by total_customers desc
--Find total customers by gender
select gender,
count(customer_key) as total_customers
from gold.dim_customers
 GROUP BY gender
 order by total_customers desc

--Total products by categary
select category,count(distinct product_key)as total_products
from gold.dim_products
group by category
order by total_products desc
--Average cost in each category
select category,
avg(cost)as avg_cost
from gold.dim_products
group by category
order by avg_cost desc

--Total revenue generated in each category
select
p.category, 
sum(f.sales_amount) as total_revenue
from gold.fact_sales f
left join gold.dim_products p
on p.product_key=f.product_key
group by p.category
order by total_revenue desc

   

-- Distribution of sold items across countries

select c.country,
sum(f.quantity) as total_sold_items
from gold .fact_sales f
left join gold.dim_customers c
on f. customer_key =c.customer_key
group by c.country
order by total_sold_items desc


--ranking

-- which 10 products generate the highest revenue 
select top 10
p.product_name,
sum(f.sales_amount) as total_revenue
from gold .fact_sales f
left join gold.dim_products p
on f.product_key =p.product_key
group by p.product_name
order by total_revenue desc

-- which 10 products generate the lowest revenue 
select top 10
p.product_name,
sum(f.sales_amount) as total_revenue
from gold .fact_sales f
left join gold.dim_products p
on f.product_key =p.product_key
group by p.product_name
order by total_revenue 
