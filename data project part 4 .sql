--Which categories contribute the most to overall sales

WITH category_sales as(
select
category,
sum(sales_amount) total_sales
from gold.fact_sales f
left join gold.dim_products p
on p.product_key=f.product_key
group by category)

select
category,
total_sales,
sum(total_sales) over() overall_sales,
concat (round((CAST(total_sales as FLOAT)/sum(total_sales)over())*100,2),'%') as percentage_of_total
from category_sales


--data segmentation

-- segment products into cost ranges and count how many products fall into each segment
with product_segments as(

select product_key,
product_name,cost,
case
    when cost<100 then 'Below 100'
	when cost between 100 AND 500 then '100-500'
	when cost between 500 AND 1000 then '500-1000'
	else 'above 1000'
end cost_range
from gold.dim_products) 
select
cost_range,
count(product_key) as total_products
from product_segments
group by cost_range
order by total_products desc




/* group cust into 3 segments based on spending behavior:
 vip: have 12 m history and 5000 spent
 regular: having 12 m of history and spent less or equal to 5000
 new: with life span less than 12 m
 and find total no cust in each group*/
with customer_spending as(
 select
 c.customer_key,
 sum(f.sales_amount) as total_spending,
 min(order_date) as first_order,
 max(order_date) as last_order,
 DATEDIFF(month, min(order_date),max(order_date)) as lifespan
 from gold.fact_sales f
 left join gold.dim_customers c
 on f.customer_key =c.customer_key
 group  by c.customer_key )

 select
 customer_segment,
 count(customer_key) as total_customers
 from(
 select
 customer_key,
 case when lifespan > =12 AND total_spending >5000 then 'Vip'
      when lifespan >= 12 AND total_spending <=5000 then 'Regular'
	  else 'New'
  end customer_segment
  from customer_spending) t
group by customer_segment
order by total_customers desc



with
(
select 
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
with customer_spending as(
 select
 c.customer_key,
 sum(f.sales_amount) as total_spending,
 min(order_date) as first_order,
 max(order_date) as last_order,
 DATEDIFF(month, min(order_date),max(order_date)) as lifespan
 from gold.fact_sales f
 left join gold.dim_customers c
 on f.customer_key =c.customer_key
 group  by c.customer_key )

 select
 customer_segment,
 count(customer_key) as total_customers
 from(
 select
 customer_key,
 case when lifespan > =12 AND total_spending >5000 then 'Vip'
      when lifespan >= 12 AND total_spending <=5000 then 'Regular'
	  else 'New'
  end customer_segment
  from customer_spending) t
group by customer_segment
order by total_customers desc


-----------------------------------------------------




------1 st customer  report



-----base query contain requeried data (core columns from the table)
---to create view <
CREATE VIEW  gold.report_customers AS


with base_query  as
(select
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
concat(c.first_name,' ',c.last_name) as customer_name,
c.birthdate,
datediff(year,birthdate,getdate()) age
from gold.fact_sales f
left join
gold.dim_customers c
on c.customer_key =f.customer_key
where order_date is not null)


--- aggregating customer level metrics as total sales,orders,quantity etc...
,customer_aggregation As(
select

customer_key,
customer_number,
 customer_name,
 age,
 count(distinct order_number) as total_orders,
 sum(sales_amount) as total_sales,
 sum(quantity) as total_quantity,
 count(distinct product_key) as total_products,
 max(order_date) as last_order_date,
 DATEDIFF(month, min(order_date),max(order_date)) as lifespan

from base_query
group by
customer_key,
customer_number,
customer_name,age)

select
customer_key,
case when lifespan > =12 AND total_sales >5000 then 'Vip'
      when lifespan >= 12 AND total_sales <=5000 then 'Regular'
	  else 'New'
end as customer_segment,
customer_name,age,
case  when age <20 then 'Under 20'
      when age between 20 and 29 then '20-29'
	  when  age between 30 and 39 then '20-29'
      when age between 40 and 49 then '20-29'
	  else '50 and above'
end as age_group,
total_orders,
total_sales,
total_quantity,
last_order_date,
--recency  since last order
datediff(month,last_order_date,getdate()) as recency,
lifespan,

-- averge order value
case when total_sales =0 then 0
else
total_sales / total_orders end as avg_order_value
,
--- average monthly spends
case when lifespan =0 THEN total_sales
    else total_sales /lifespan
END AS avg_monthly_spend

from customer_aggregation



--2 nd product report

CREATE VIEW  gold.report_productss AS


with base_query  as
(select
f.order_number,
f.order_date,
f.customer_key,
f.sales_amount,
f.quantity,
f.product_key,
p.product_name,
p.category,
p.subcategory,
p.cost

from gold.fact_sales f
left join
gold.dim_products p 
on f.product_key =p.product_key
where order_date is not null),


--- aggregating product level metrics as total sales,orders,quantity etc...
product_aggregation As(
select
	product_key,
	product_name,
	category,
	cost,
	subcategory,
     DATEDIFF(month, min(order_date),max(order_date)) as lifespan,
	 max(order_date) as last_sale_date,
     count(distinct order_number) as total_orders,
	 count(distinct customer_key) as total_customers,
     sum(sales_amount) as total_sales,
     sum(quantity) as total_quantity,
     Round(avg(cast(sales_amount as FLOAT)/ NULLIF(quantity,0)),1) as avg_selling_price

from base_query
group by
    product_key,
	product_name,
	category,cost,
	subcategory)
	-------final query combain all product results into one output
select
    product_key,
	product_name,
	subcategory,
	cost,
	category,
	last_sale_date,
    datediff(month,last_sale_date,getdate()) as recency_in_months,
	case  
	  when total_sales > 5000 then 'High-performence'
	  when total_sales >= 10000 then 'Mid-range'
      else 'low-performer'	 
end as product_segment,

lifespan,
total_orders,
total_sales,
total_quantity,
total_customers,
avg_selling_price,

-- averge order revenue
case when total_orders =0 then 0
else
total_sales / total_orders end as avg_order_revenue,

--- average monthly revenue
case when lifespan =0 THEN total_sales
    else total_sales /lifespan
END AS avg_monthly_revenue

from product_aggregation

