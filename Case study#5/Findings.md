## Data Exploration
Check out the queries [Here](https://github.com/roysushmita/8-weeks-SQL-challenge/blob/main/Case%20study%235/SQL%20query/Data%20exploration-CS5.sql)


### 1. Data Cleaning Steps
In a single query, perform the following operations and generate a new table in the data_mart schema named clean_weekly_sales:
•Convert the week_date to a DATE format

•Add a week_number as the second column for each week_date value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc

•Add a month_number with the calendar month for each week_date value as the 3rd column

•Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values

•Add a new column called age_band after the original segment column using the following mapping on the number inside the segment value

![image](https://github.com/roysushmita/8-weeks-SQL-challenge/assets/129031314/6b017e86-bfbe-4925-be98-9166f5dbcc12)


•Add a new demographic column using the following mapping for the first letter in the segment values:

![image](https://github.com/roysushmita/8-weeks-SQL-challenge/assets/129031314/4549a55d-59b0-4595-b2e5-d0bcbc4f067e)


•Ensure all null string values with an "unknown" string value in the original segment column as well as the new age_band and demographic columns

•Generate a new avg_transaction column as the sales value divided by transactions rounded to 2 decimal places for each record

--Creating table:
```
CREATE TABLE clean_weekly_sales(
	week_date DATE,
	week_number INTEGER,
	month_number INTEGER,
	calendar_year INTEGER,
	region VARCHAR(15),
	platform VARCHAR(10),
	segment VARCHAR(15),
	age_band VARCHAR(20) not null,
	demographic VARCHAR(20) not null,
	customer_type VARCHAR(10),
	transactions INTEGER,
	sales INTEGER,
	avg_transaction float
)
```
--inserting values in the columns of clean_weekly_sales

```
INSERT INTO clean_weekly_sales(week_date,week_number,month_number, calendar_year,region,platform,segment,
							  age_band,demographic,customer_type,transactions,sales,avg_transaction)
SELECT TO_DATE(week_date, 'DD/MM/YY') as week_date,
	   DATE_PART('week', TO_DATE(week_date, 'DD/MM/YY')) as week_number,
  	   DATE_PART('month', TO_DATE(week_date, 'DD/MM/YY')) as month_number,
       DATE_PART('year', TO_DATE(week_date, 'DD/MM/YY')) as calendar_year,
	   region, platform, 
	   CASE WHEN segment='null' THEN 'unknown' ELSE segment END AS segment,
	   CASE WHEN right(segment,1) = '1' THEN 'Young Adults'
            WHEN right(segment,1) = '2' THEN 'Middle Aged'
            WHEN right(segment,1) in ('3','4') THEN 'Retirees'
            ELSE 'unknown' END as age_band,
	 CASE WHEN left(segment,1) = 'C' THEN 'Couples'
    	  WHEN left(segment,1) = 'F' THEN 'Families'
    	  ELSE 'unknown' END as demographic,
     customer_type,transactions,sales,
	 ROUND((sales/transactions),2) as avg_transaction
FROM weekly_sales;
```

```
SELECT * FROM clean_weekly_sales
```
| week_date   | week_number | month_number | calendar_year | region  | platform | segment | age_band      | demographic | customer_type | transactions | sales      | avg_transaction |
|-------------|-------------|--------------|----------------|---------|----------|---------|---------------|-------------|----------------|--------------|------------|------------------|
| 2020-08-31  | 36          | 8            | 2020           | ASIA    | Retail   | C3      | Retirees       | Couples     | New            | 120,631      | 3,656,163  | 30               |
| 2020-08-31  | 36          | 8            | 2020           | ASIA    | Retail   | F1      | Young Adults   | Families    | New            | 31,574       | 996,575    | 31               |
| 2020-08-31  | 36          | 8            | 2020           | USA     | Retail   | unknown | unknown        | unknown     | Guest          | 529,151      | 16,509,610 | 31               |
| 2020-08-31  | 36          | 8            | 2020           | EUROPE  | Retail   | C1      | Young Adults   | Couples     | New            | 4,517        | 141,942    | 31               |
| 2020-08-31  | 36          | 8            | 2020           | AFRICA  | Retail   | C2      | Middle Aged    | Couples     | New            | 58,046       | 1,758,388  | 30               |
| 2020-08-31  | 36          | 8            | 2020           | CANADA  | Shopify  | F2      | Middle Aged    | Families    | Existing       | 1,336        | 243,878    | 182              |
| 2020-08-31  | 36          | 8            | 2020           | AFRICA  | Shopify  | F3      | Retirees       | Families    | Existing       | 2,514        | 519,502    | 206              |
| 2020-08-31  | 36          | 8            | 2020           | ASIA    | Shopify  | F1      | Young Adults   | Families    | Existing       | 2,158        | 371,417    | 172              |
| 2020-08-31  | 36          | 8            | 2020           | AFRICA  | Shopify  | F2      | Middle Aged    | Families    | New            | 318          | 49,557     | 155              |
| 2020-08-31  | 36          | 8            | 2020           | AFRICA  | Retail   | C3      | Retirees       | Couples     | New            | 111,032      | 3,888,162  | 35               |

##

### 2. Data Exploration
--1. What day of the week is used for each week_date value?
```
SELECT DISTINCT(to_char(week_date,'day'))
AS week_day
FROM clean_weekly_sales;
```
| week_day |
|----------|
| Monday   |

--2. What range of week numbers are missing from the dataset?
```
WITH week_number_cte AS (SELECT GENERATE_SERIES(1,52) AS week_number)
SELECT DISTINCT cte.week_number
FROM week_number_cte cte
LEFT OUTER JOIN
clean_weekly_sales csw
ON cte.week_number = csw.week_number
WHERE csw.week_number IS NULL;
```
| week_number |
|-------------|
| 1           |
| 2           |
| 3           |
| 4           |
| 5           |
| 6           |
| 7           |
| 8           |
| 9           |
| 10          |
| 11          |
| 12          |
| 37          |
| 38          |
| 39          |
| 40          |
| 41          |
| 42          |
| 43          |
| 44          |
| 45          |
| 46          |
| 47          |
| 48          |
| 49          |
| 50          |
| 51          |
| 52          |

--3. How many total transactions were there for each year in the dataset?
```
SELECT calendar_year,SUM(transactions) as total_transaction
FROM clean_weekly_sales
GROUP BY calendar_year;
```
| calendar_year | total_transaction       |
|------|-------------|
| 2018 | 346,406,460 |
| 2019 | 365,639,285 |
| 2020 | 375,813,651 |

--4. What is the total sales for each region for each month?
```
SELECT region,month_number,SUM(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY region,month_number
ORDER BY region,month_number;
```
| region | month_number | total_sales |
|--------|--------------|-------------|
| AFRICA | 3            | 567767480   |
| AFRICA | 4            | 1911783504  |
| AFRICA | 5            | 1647244738  |
| AFRICA | 6            | 1767559760  |
| AFRICA | 7            | 1960219710  |
| AFRICA | 8            | 1809596890  |
| AFRICA | 9            | 276320987   |
| ASIA   | 3            | 529770793   |
| ASIA   | 4            | 1804628707  |
| ASIA   | 5            | 1526285399  |
| ASIA   | 6            | 1619482889  |
| ASIA   | 7            | 1768844756  |
| ASIA   | 8            | 1663320609  |
| ASIA   | 9            | 252836807   |
| CANADA | 3            | 144634329   |
| CANADA | 4            | 484552594   |
| CANADA | 5            | 412378365   |
| CANADA | 6            | 443846698   |
| CANADA | 7            | 477134947   |
| CANADA | 8            | 447073019   |
| CANADA | 9            | 69067959    |
| EUROPE | 3            | 35337093    |

--5. What is the total count of transactions for each platform
```
SELECT platform,SUM(transactions) AS total_count_transaction
FROM clean_weekly_sales
GROUP BY platform;
```
| platform  | total_count_transaction |
|-----------|--------------------------|
| Shopify   | 5,925,169               |
| Retail    | 1,081,934,227           |

--6. What is the percentage of sales for Retail vs Shopify for each month
```
WITH transaction_cte AS (SELECT calendar_year,month_number,platform,SUM(sales) AS monthly_plat_sales
FROM clean_weekly_sales
GROUP BY calendar_year, month_number, platform)
SELECT calendar_year, month_number,
ROUND(100.0 * SUM(CASE WHEN platform = 'Retail' THEN monthly_plat_sales END)/SUM(monthly_plat_sales),2) AS retail_percentage,
100-ROUND(100.0 *  SUM(CASE WHEN platform = 'Retail' THEN monthly_plat_sales END)/SUM(monthly_plat_sales),2) AS shopify_percentage
FROM transaction_cte
GROUP BY calendar_year,month_number;
```
| calendar_year | month_number | retail_percentage | shopify_percentage |
|---------------|--------------|---------------------|----------------------|
| 2018          | 3            | 97.92               | 2.08                 |
| 2018          | 4            | 97.93               | 2.07                 |
| 2018          | 5            | 97.73               | 2.27                 |
| 2018          | 6            | 97.76               | 2.24                 |
| 2018          | 7            | 97.75               | 2.25                 |
| 2018          | 8            | 97.71               | 2.29                 |
| 2018          | 9            | 97.68               | 2.32                 |
| 2019          | 3            | 97.71               | 2.29                 |
| 2019          | 4            | 97.80               | 2.20                 |
| 2019          | 5            | 97.52               | 2.48                 |
| 2019          | 6            | 97.42               | 2.58                 |
| 2019          | 7            | 97.35               | 2.65                 |
| 2019          | 8            | 97.21               | 2.79                 |
| 2019          | 9            | 97.09               | 2.91                 |
| 2020          | 3            | 97.30               | 2.70                 |
| 2020          | 4            | 96.96               | 3.04                 |
| 2020          | 5            | 96.71               | 3.29                 |
| 2020          | 6            | 96.80               | 3.20                 |
| 2020          | 7            | 96.67               | 3.33                 |
| 2020          | 8            | 96.51               | 3.49                 |

OR

```
WITH temp_cte AS (SELECT calendar_year, month_number, platform,SUM(sales) AS monthly_plat_sales
				  FROM clean_weekly_sales GROUP BY calendar_year, month_number, platform)
SELECT calendar_year, month_number, platform,
ROUND(100 * (monthly_plat_sales/ SUM(monthly_plat_sales) OVER(PARTITION BY calendar_year, month_number)),2) 
AS sale_percentage
FROM temp_cte;
```
| calendar_year | month_number | platform | sale_percentage |
|---------------|--------------|----------|------------------|
| 2018          | 3            | Shopify  | 2.08             |
| 2018          | 3            | Retail   | 97.92            |
| 2018          | 4            | Shopify  | 2.07             |
| 2018          | 4            | Retail   | 97.93            |
| 2018          | 5            | Shopify  | 2.27             |
| 2018          | 5            | Retail   | 97.73            |
| 2018          | 6            | Retail   | 97.76            |
| 2018          | 6            | Shopify  | 2.24             |
| 2018          | 7            | Shopify  | 2.25             |
| 2018          | 7            | Retail   | 97.75            |
| 2018          | 8            | Shopify  | 2.29             |
| 2018          | 8            | Retail   | 97.71            |
| 2018          | 9            | Retail   | 97.68            |
| 2018          | 9            | Shopify  | 2.32             |
| 2019          | 3            | Shopify  | 2.29             |
| 2019          | 3            | Retail   | 97.71            |
| 2019          | 4            | Shopify  | 2.20             |
| 2019          | 4            | Retail   | 97.80            |
| 2019          | 5            | Shopify  | 2.48             |
| 2019          | 5            | Retail   | 97.52            |
| 2019          | 6            | Retail   | 97.42            |
| 2019          | 6            | Shopify  | 2.58             |
| 2019          | 7            | Shopify  | 2.65             |
| 2019          | 7            | Retail   | 97.35            |
| 2019          | 8            | Retail   | 97.21            |
| 2019          | 8            | Shopify  | 2.79             |
| 2019          | 9            | Shopify  | 2.91             |
| 2019          | 9            | Retail   | 97.09            |
| 2020          | 3            | Retail   | 97.30            |
| 2020          | 3            | Shopify  | 2.70             |
| 2020          | 4            | Retail   | 96.96            |
| 2020          | 4            | Shopify  | 3.04             |
| 2020          | 5            | Shopify  | 3.29             |
| 2020          | 5            | Retail   | 96.71            |
| 2020          | 6            | Shopify  | 3.20             |
| 2020          | 6            | Retail   | 96.80            |
| 2020          | 7            | Retail   | 96.67            |
| 2020          | 7            | Shopify  | 3.33             |
| 2020          | 8            | Retail   | 96.51            |
| 2020          | 8            | Shopify  | 3.49             |
	  
--7. What is the percentage of sales by demographic for each year in the dataset?
```
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
```
| calendar_year | family_percentage | couple_percentage | unknown_percentage |
|---------------|---------------------|---------------------|----------------------|
| 2018          | 31.99               | 26.38               | 41.63                |
| 2019          | 32.47               | 27.28               | 40.25                |
| 2020          | 32.73               | 28.72               | 38.55                |

OR

```
WITH temp_cte as (SELECT calendar_year,demographic,
				 SUM(sales) as yearly_demo_sale
				 FROM clean_weekly_sales GROUP BY calendar_year,demographic)
SELECT calendar_year,demographic,
ROUND(100.0* yearly_demo_sale/ SUM(yearly_demo_sale) OVER(PARTITION BY calendar_year),2) as percentage_sale
FROM temp_cte ORDER BY calendar_year,demographic;
```
| calendar_year | demographic | percentage_sale |
|---------------|-------------|------------------|
| 2018          | Couples     | 26.38            |
| 2018          | Families    | 31.99            |
| 2018          | Unknown     | 41.63            |
| 2019          | Couples     | 27.28            |
| 2019          | Families    | 32.47            |
| 2019          | Unknown     | 40.25            |
| 2020          | Couples     | 28.72            |
| 2020          | Families    | 32.73            |
| 2020          | Unknown     | 38.55            |

--8. Which age_band and demographic values contribute the most to Retail sales?
```
SELECT age_band,demographic,SUM(sales) AS retail_contribution,
ROUND(100.0 * SUM(sales)/SUM(SUM(sales)) OVER(),2) AS contribution_percentage
FROM clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY age_band,demographic
ORDER BY retail_contribution DESC;
```
| age_band     | demographic | retail_contribution | contribution_percentage |
|---------------|--------------|----------------------|--------------------------|
| unknown       | unknown      | 16,067,285,533      | 40.52                    |
| Retirees      | Families     | 6,634,686,916       | 16.73                    |
| Retirees      | Couples      | 6,370,580,014       | 16.07                    |
| Middle Aged   | Families     | 4,354,091,554       | 10.98                    |
| Young Adults  | Couples      | 2,602,922,797       | 6.56                     |
| Middle Aged   | Couples      | 1,854,160,330       | 4.68                     |
| Young Adults  | Families     | 1,770,889,293       | 4.47                     |

--9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
```
SELECT calendar_year,platform,round(SUM(sales)/SUM(transactions),2) correct_avg_size, 
round(AVG(avg_transaction)::NUMERIC,2) incorrect_avg_size
FROM clean_weekly_sales 
GROUP BY calendar_year,platform ORDER BY calendar_year;
```
| calendar_year | platform | correct_avg_size | incorrect_avg_size |
|---------------|----------|-------------------|---------------------|
| 2018          | Retail   | 36.00             | 42.41               |
| 2018          | Shopify  | 192.00            | 187.80              |
| 2019          | Retail   | 36.00             | 41.47               |
| 2019          | Shopify  | 183.00            | 177.07              |
| 2020          | Shopify  | 179.00            | 174.40              |
| 2020          | Retail   | 36.00             | 40.14               |

##

### 3. Before & After Analysis
This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.

Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging changes came into effect.

We would include all week_date values for 2020-06-15 as the start of the period after the change and the previous week_date values would be before

Using this analysis approach - answer the following questions:
1. What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?
2. What about the entire 12 weeks before and after?
3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?
   
```
SELECT DISTINCT(DATE_PART('week',week_date)) as week_number
FROM clean_weekly_sales
WHERE week_date = '2020-06-15';
```
| week_number |
|-------------|
| 25          |


--1. What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?
```
with temp_cte AS (SELECT
SUM(CASE WHEN (week_number BETWEEN 21 AND 24)
THEN sales END) AS before_change,
SUM(CASE WHEN (week_number BETWEEN 25 AND 28) THEN sales END) AS after_change
FROM clean_weekly_sales
WHERE calendar_year = 2020)
SELECT before_change,after_change,after_change-before_change AS sale_change,
ROUND((100.0* (after_change-before_change)/before_change),2) AS rate_of_change
FROM temp_cte;
```
| before_change | after_change | sale_change | rate_of_change |
|---------------|--------------|-------------|----------------|
| 2,345,878,357 | 2,318,994,169 | -26,884,188 | -1.15          |


--2. What about the entire 12 weeks before and after?
```
with temp_cte AS (SELECT
SUM(CASE WHEN (week_number BETWEEN 13 AND 24)
THEN sales END) AS before_change,
SUM(CASE WHEN (week_number BETWEEN 25 AND 36) THEN sales END) AS after_change
FROM clean_weekly_sales
WHERE calendar_year = 2020)
SELECT before_change,after_change,after_change-before_change AS sale_change,
ROUND((100.0* (after_change-before_change)/before_change),2) AS rate_of_change
FROM temp_cte;
```
| before_change | after_change | sale_change  | rate_of_change |
|---------------|--------------|--------------|-----------------|
| 7,126,273,147 | 6,973,947,753 | -152,325,394 | -2.14           |

--3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?
```
WITH temp_cte AS (SELECT calendar_year,
SUM(CASE WHEN (week_number BETWEEN 21 AND 24) THEN sales END) before_change,
SUM(CASE WHEN (week_number BETWEEN 25 AND 28) THEN sales END) after_change
FROM clean_weekly_sales GROUP BY calendar_year)
SELECT calendar_year,before_change,after_change,after_change-before_change AS sale_change,
ROUND((100.0* (after_change-before_change)/before_change),2) AS rate_of_change
FROM temp_cte;
```
| calendar_year | before_change | after_change | sale_change  | rate_of_change |
|---------------|---------------|--------------|--------------|-----------------|
| 2018          | 2,125,140,809 | 2,129,242,914 | 4,102,105    | 0.19            |
| 2019          | 2,249,989,796 | 2,252,326,390 | 2,336,594    | 0.10            |
| 2020          | 2,345,878,357 | 2,318,994,169 | -26,884,188  | -1.15           |


```
WITH temp_cte AS (SELECT calendar_year,
SUM(CASE WHEN (week_number BETWEEN 13 AND 24) THEN sales END) before_change,
SUM(CASE WHEN (week_number BETWEEN 25 AND 36) THEN sales END) after_change
FROM clean_weekly_sales GROUP BY calendar_year)
SELECT calendar_year,before_change,after_change,after_change-before_change AS sale_change,
ROUND((100.0* (after_change-before_change)/before_change),2) AS rate_of_change
FROM temp_cte;
```
| calendar_year | before_change | after_change | sale_change   | rate_of_change |
|---------------|---------------|--------------|---------------|-----------------|
| 2018          | 6,396,562,317 | 6,500,818,510 | 104,256,193   | 1.63            |
| 2019          | 6,883,386,397 | 6,862,646,103 | -20,740,294   | -0.30           |
| 2020          | 7,126,273,147 | 6,973,947,753 | -152,325,394  | -2.14           |
