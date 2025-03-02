-- 1 Data Exploration & Cleaning
-- 1.1 Determine the total number of records in the dataset.
select COUNT(*) as 'Total Records' from Retail_Sales_Analysis
-- 1.2 Find out how many unique customers are in the dataset.
select count(distinct customer_id) as 'Unique Customers'from Retail_Sales_Analysis
-- 1.3 Identify all unique product categories in the dataset.
select distinct category as 'Categories' from Retail_Sales_Analysis
go
-- 1.4 Fix Incorrect Column Names
exec sp_rename 'Retail_Sales_Analysis.quantiy','quantity','Column'
exec sp_rename 'Retail_Sales_Analysis.total_sale','total_sales','Column'
go
-- 1.5 Check for any null values in the dataset and delete records with missing data.
-- check
select * from Retail_Sales_Analysis
where  sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;
-- delete
delete from Retail_Sales_Analysis
where  sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;
go
-- 2 Data Analysis and Findings
go
-- 2.1 Retrieve all columns for sales made on '2022-11-05':
declare @my_date DATE
set @my_date = '2022-11-05'
select * from Retail_Sales_Analysis
where sale_date = @my_date
go
-- 2.2 Retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022:
select * from Retail_Sales_Analysis
where category = 'Clothing' and quantity >= 4 and 
MONTH(sale_date) = 11 and YEAR(sale_date) = 2022
go
-- 2.3 Calculate the total sales (total_sale) for each category.
select 
category, 
concat(sum(total_sales),' $')as 'Total Sales'
from Retail_Sales_Analysis
group by category
go
-- 2.4 Find the average age of customers who purchased items from the 'Beauty' category.
SELECT 
    ROUND(AVG(age),2) AS "Average Age"
FROM Retail_Sales_Analysis
WHERE category = 'Beauty';
go
-- 2.5 Find all transactions where the total_sale is greater than 1000.
select * from Retail_Sales_Analysis
where total_sales >= 1000
go
-- 2.6 Find the total number of transactions (transaction_id) made by each gender in each category.
select 
category,
gender,
COUNT(*) as 'Total Transactions'
from Retail_Sales_Analysis
group by gender, category
order by 3 desc
go
-- 2.7 Calculate the average sale for each month. Find out best selling month in each year:
select 
Months,
Years,
Monthly_AVG_Sales,
Rank
from (select 
DATENAME(MONTH,sale_date) as 'Months',
DATEPART(YEAR,sale_date) as 'Years',
CONCAT(ROUND(AVG(total_sales),2),' $') as 'Monthly_AVG_Sales',
RANK() over(partition by DATEPART(YEAR,sale_date) order by AVG(total_sales) desc) as 'Rank'
from Retail_Sales_Analysis
group by DATEPART(MONTH, sale_date), DATENAME(MONTH, sale_date), DATEPART(YEAR, sale_date)
) as T1
where Rank = 1
go
-- 2.8 Find the top 5 customers based on the highest total sales
select top 5
customer_id,
SUM(total_sales) as 'Total Sales'
from Retail_Sales_Analysis
group by customer_id
ORDER BY SUM(total_sales) DESC
go
-- 2.9 Find the number of unique customers who purchased items from each category.
select
category,
COUNT(distinct customer_id) as 'Unique Customers'
from Retail_Sales_Analysis
group by category
go
-- 2.10 Create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17):
with Hourly_Orders 
as (select *,
Case
	when DATEPART(HOUR,sale_time) < 12 then 'Morning'
	when DATEPART(HOUR,sale_time) between 12 and 17 then 'Afternoon'
	else 'Evening'
end as 'Shifts' 
from Retail_Sales_Analysis
)
select 
Shifts,
COUNT(*) as 'Total Orders'
from Hourly_Orders
group by Shifts
go