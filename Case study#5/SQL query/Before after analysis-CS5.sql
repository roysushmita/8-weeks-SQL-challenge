'''
3. Before & After Analysis
Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable
packaging changes came into effect.
We would include all week_date values for 2020-06-15 as the start of the period after the change
and the previous week_date values would be before
'''
SELECT DISTINCT(DATE_PART('week',week_date)) as week_number
FROM clean_weekly_sales
WHERE week_date = '2020-06-15';
-------------------------------------------------------------------------------------------------------------------------------------------------
--1. What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?
with temp_cte AS (SELECT
SUM(CASE WHEN (week_number BETWEEN 21 AND 24)
THEN sales END) AS before_change,
SUM(CASE WHEN (week_number BETWEEN 25 AND 28) THEN sales END) AS after_change
FROM clean_weekly_sales
WHERE calendar_year = 2020)
SELECT before_change,after_change,after_change-before_change AS sale_change,
ROUND((100.0* (after_change-before_change)/before_change),2) AS rate_of_change
FROM temp_cte;


--2. What about the entire 12 weeks before and after?
with temp_cte AS (SELECT
SUM(CASE WHEN (week_number BETWEEN 13 AND 24)
THEN sales END) AS before_change,
SUM(CASE WHEN (week_number BETWEEN 25 AND 36) THEN sales END) AS after_change
FROM clean_weekly_sales
WHERE calendar_year = 2020)
SELECT before_change,after_change,after_change-before_change AS sale_change,
ROUND((100.0* (after_change-before_change)/before_change),2) AS rate_of_change
FROM temp_cte;

--3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?
WITH temp_cte AS (SELECT calendar_year,
SUM(CASE WHEN (week_number BETWEEN 21 AND 24) THEN sales END) before_change,
SUM(CASE WHEN (week_number BETWEEN 25 AND 28) THEN sales END) after_change
FROM clean_weekly_sales GROUP BY calendar_year)
SELECT calendar_year,before_change,after_change,after_change-before_change AS sale_change,
ROUND((100.0* (after_change-before_change)/before_change),2) AS rate_of_change
FROM temp_cte;


WITH temp_cte AS (SELECT calendar_year,
SUM(CASE WHEN (week_number BETWEEN 13 AND 24) THEN sales END) before_change,
SUM(CASE WHEN (week_number BETWEEN 25 AND 36) THEN sales END) after_change
FROM clean_weekly_sales GROUP BY calendar_year)
SELECT calendar_year,before_change,after_change,after_change-before_change AS sale_change,
ROUND((100.0* (after_change-before_change)/before_change),2) AS rate_of_change
FROM temp_cte;
