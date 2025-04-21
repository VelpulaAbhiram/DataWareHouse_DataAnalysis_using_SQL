--Change overtime trends

select 
FORMAT(order_date,'yyyy-MMM') as order_year,
sum(sales_amount) as total_sales
,count(distinct customer_key) as total_customers ,
sum(quantity) as total_quantity
from gold.fact_sales
where order_date is not null
group by FORMAT(order_date,'yyyy-MMM')
order by FORMAT(order_date,'yyyy-MMM')

--cumulative  analysis


--calculate the total sales per month or year
--and the running total of sales over time
select
order_date,
total_sales,
sum(total_sales) over(partition by order_date order by order_date) as running_total_sales,
avg(avg_price) over(partition by order_date order by order_date) as moving_average_price

from 
(
select 
DATETRUNC(year,order_date)as order_date,
sum(sales_amount) as total_sales,
avg(price) as avg_price
from gold.fact_sales
where order_date IS NOT NULL
group by DATETRUNC(year,order_date)

) t


--performance analysis


 /* analyze the yearly performance of products by comparing their sales
 to both the average sales performance of the product and the previous year sales*/
 
with yearly_product_sales
as
 (
select
year(f.order_date) as order_year,
d.product_name,
sum(f.sales_amount) as current_sales
from gold.fact_sales f
left join gold.dim_products d
on f.product_key =d.product_key
where f.order_date IS NOT NULL
group by  year(f.order_date),d.product_name
)
select
order_year,
product_name,
current_sales,
avg(current_sales) over(partition by product_name) avg_sales,
current_sales - avg(current_sales) over(partition by product_name) as diff_avg,
case when current_sales - avg(current_sales) over(partition by product_name) >0 then 'Above Avg'
     when current_sales - avg(current_sales) over(partition by product_name) <0 then 'Below Avg'
	 else 'Avg'
end avg_change,
-- lag is a window fuction used to find previous data
lag(current_sales) over(partition by product_name order by order_year) Py_sales,
current_sales -lag(current_sales) over(partition by product_name order by order_year)  as diff_py,
  case when current_sales -lag(current_sales) over(partition by product_name order by order_year) >0 then 'Increase'
     when current_sales -lag(current_sales) over(partition by product_name order by order_year) <0 then 'Decrease '
	 else 'No change'
	end Py_change
from yearly_product_sales
order by
product_name ,order_year


-- part to whole analysis


