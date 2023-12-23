/*In a single query, perform the following operations and generate a new table in the data_mart schema named clean_weekly_sales:
•Convert the week_date to a DATE format
•Add a week_number as the second column for each week_date value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc
•Add a month_number with the calendar month for each week_date value as the 3rd column
•Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values
•Add a new column called age_band after the original segment column using the following mapping on the number inside the segment value
•Add a new demographic column using the following mapping for the first letter in the segment values:
•Ensure all null string values with an "unknown" string value in the original segment column as well as the new age_band and demographic columns
•Generate a new avg_transaction column as the sales value divided by transactions rounded to 2 decimal places for each record
*/


--Creating table:
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
--inserting values in the columns of clean_weekly_sales

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


