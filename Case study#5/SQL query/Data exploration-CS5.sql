--1. What day of the week is used for each week_date value?
SELECT DISTINCT(to_char(week_date,'day'))
AS week_day
FROM clean_weekly_sales;

--2. What range of week numbers are missing from the dataset?
WITH week_number_cte AS (SELECT GENERATE_SERIES(1,52) AS week_number)
SELECT DISTINCT cte.week_number
FROM week_number_cte cte
LEFT OUTER JOIN
clean_weekly_sales csw
ON cte.week_number = csw.week_number
WHERE csw.week_number IS NULL;

--3. How many total transactions were there for each year in the dataset?
SELECT calendar_year,SUM(transactions) as total_transaction
FROM clean_weekly_sales
GROUP BY calendar_year;

--4. What is the total sales for each region for each month?
SELECT region,month_number,SUM(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY region,month_number
ORDER BY region,month_number;

--5. What is the total count of transactions for each platform
SELECT platform,SUM(transactions) AS total_count_transaction
FROM clean_weekly_sales
GROUP BY platform;

--6. What is the percentage of sales for Retail vs Shopify for each month
WITH transaction_cte AS (SELECT calendar_year,month_number,platform,SUM(sales) AS monthly_plat_sales
FROM clean_weekly_sales
GROUP BY calendar_year, month_number, platform)
SELECT calendar_year, month_number,
ROUND(100.0 * SUM(CASE WHEN platform = 'Retail' THEN monthly_plat_sales END)/SUM(monthly_plat_sales),2) AS retail_percentage,
100-ROUND(100.0 *  SUM(CASE WHEN platform = 'Retail' THEN monthly_plat_sales END)/SUM(monthly_plat_sales),2) AS shopify_percentage
FROM transaction_cte
GROUP BY calendar_year,month_number;

'''[OR]'''

WITH temp_cte AS (SELECT calendar_year, month_number, platform,SUM(sales) AS monthly_plat_sales
				  FROM clean_weekly_sales GROUP BY calendar_year, month_number, platform)
SELECT calendar_year, month_number, platform,
ROUND(100 * (monthly_plat_sales/ SUM(monthly_plat_sales) OVER(PARTITION BY calendar_year, month_number)),2) 
AS sale_percentage
FROM temp_cte;
	  
--7. What is the percentage of sales by demographic for each year in the dataset?
WITH transaction_cte AS (SELECT calendar_year, demographic,SUM(sales) AS yearly_demo_sales
FROM clean_weekly_sales
GROUP BY calendar_year, demographic)
SELECT calendar_year,
ROUND(100.0 * SUM (CASE WHEN demographic = 'Families' THEN yearly_demo_sales END)/SUM(yearly_demo_sales),2)
AS family_percentage,
ROUND(100.0 * SUM (CASE WHEN demographic = 'Couples' THEN yearly_demo_sales END)/SUM(yearly_demo_sales),2)
AS couple_percentage,
ROUND(100.0 * SUM (CASE WHEN demographic = 'unknown' THEN yearly_demo_sales END)/SUM(yearly_demo_sales),2) 
AS unknown_percentage
FROM transaction_cte
GROUP BY calendar_year;

'''[or]'''

WITH temp_cte as (SELECT calendar_year,demographic,
				 SUM(sales) as yearly_demo_sale
				 FROM clean_weekly_sales GROUP BY calendar_year,demographic)
SELECT calendar_year,demographic,
ROUND(100.0* yearly_demo_sale/ SUM(yearly_demo_sale) OVER(PARTITION BY calendar_year),2) percentage_sale
FROM temp_cte ORDER BY calendar_year,demographic;

--8. Which age_band and demographic values contribute the most to Retail sales?
SELECT age_band,demographic,SUM(sales) AS retail_contribution,
ROUND(100.0 * SUM(sales)/SUM(SUM(sales)) OVER(),2) AS contribution_percentage
FROM clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY age_band,demographic
ORDER BY retail_contribution DESC;

--9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
SELECT calendar_year,platform,round(SUM(sales)/SUM(transactions),2) correct_avg_size, 
round(AVG(avg_transaction)::NUMERIC,2) incorrect_avg_size
FROM clean_weekly_sales 
GROUP BY calendar_year,platform ORDER BY calendar_year;
