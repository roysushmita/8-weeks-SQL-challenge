/*
Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?

region
platform
age_band
demographic
customer_type
Do you have any further recommendations for Danny’s team at Data Mart or any interesting insights based off this analysis?
*/
--Impact on region
WITH temp_cte AS (SELECT region,
SUM(CASE WHEN (week_number BETWEEN 13 AND 24 AND calendar_year=2020) THEN sales END) before_change,
SUM(CASE WHEN (week_number BETWEEN 25 AND 36 AND calendar_year=2020) THEN sales END) after_change
FROM clean_weekly_sales 
GROUP BY region)
SELECT region,before_change,after_change,after_change-before_change AS sale_change,
ROUND((100.0* (after_change-before_change)/before_change),2) AS rate_of_change
FROM temp_cte ORDER BY rate_of_change;


--Impact on platform
WITH temp_cte AS (SELECT platform,
SUM(CASE WHEN (week_number BETWEEN 13 AND 24 AND calendar_year=2020) THEN sales END) before_change,
SUM(CASE WHEN (week_number BETWEEN 25 AND 36 AND calendar_year=2020) THEN sales END) after_change
FROM clean_weekly_sales 
GROUP BY platform)
SELECT platform,before_change,after_change,after_change-before_change AS sale_change,
ROUND((100.0* (after_change-before_change)/before_change),2) AS rate_of_change
FROM temp_cte ORDER BY rate_of_change;


--Impact on age_band
WITH temp_cte AS (SELECT age_band,
SUM(CASE WHEN (week_number BETWEEN 13 AND 24 AND calendar_year=2020) THEN sales END) before_change,
SUM(CASE WHEN (week_number BETWEEN 25 AND 36 AND calendar_year=2020) THEN sales END) after_change
FROM clean_weekly_sales 
GROUP BY age_band)
SELECT age_band,before_change,after_change,after_change-before_change AS sale_change,
ROUND((100.0* (after_change-before_change)/before_change),2) AS rate_of_change
FROM temp_cte ORDER BY rate_of_change;


--Impact on demographic
WITH temp_cte AS (SELECT demographic,
SUM(CASE WHEN (week_number BETWEEN 13 AND 24 AND calendar_year=2020) THEN sales END) before_change,
SUM(CASE WHEN (week_number BETWEEN 25 AND 36 AND calendar_year=2020) THEN sales END) after_change
FROM clean_weekly_sales 
GROUP BY demographic)
SELECT demographic,before_change,after_change,after_change-before_change AS sale_change,
ROUND((100.0* (after_change-before_change)/before_change),2) AS rate_of_change
FROM temp_cte ORDER BY rate_of_change;


--Impact on customer_type
WITH temp_cte AS (SELECT customer_type,
SUM(CASE WHEN (week_number BETWEEN 13 AND 24 AND calendar_year=2020) THEN sales END) before_change,
SUM(CASE WHEN (week_number BETWEEN 25 AND 36 AND calendar_year=2020) THEN sales END) after_change
FROM clean_weekly_sales 
GROUP BY customer_type)
SELECT customer_type,before_change,after_change,after_change-before_change AS sale_change,
ROUND((100.0* (after_change-before_change)/before_change),2) AS rate_of_change
FROM temp_cte ORDER BY rate_of_change;