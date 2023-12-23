--1. What is the total amount each customer spent at the restaurant?
SELECT customer_id,SUM(price) FROM menu m 
FULL OUTER JOIN sales s
ON m.product_id = s.product_id
GROUP BY customer_id;

--2. How many days has each customer visited the restaurant?
SELECT customer_id,COUNT(DISTINCT order_date) AS visited_days FROM sales s1 GROUP BY customer_id;

--3. What was the first item from the menu purchased by each customer?
WITH temp_cte AS (SELECT customer_id,s.product_id,order_date,product_name 
				 FROM  sales s FULL OUTER JOIN menu ON menu.product_id = s.product_id)
	SELECT DISTINCT(customer_id),FIRST_VALUE(product_name) OVER(PARTITION BY customer_id ORDER BY order_date)
	FROM temp_cte;

--4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT ms.product_name,COUNT(ms.order_date) total_order 
	FROM (menu mn INNER JOIN sales s ON s.product_id = mn.product_id) ms
		INNER JOIN members mm ON mm.customer_id = ms.customer_id 
	GROUP BY ms.product_name
	ORDER BY total_order DESC
	LIMIT 1;

--5. Which item was the most popular for each customer?
WITH temp_cte AS (SELECT customer_id,product_id,COUNT(product_id) AS counts FROM sales
				 GROUP BY customer_id,product_id)
				 SELECT DISTINCT(customer_id),FIRST_VALUE(product_name) OVER(PARTITION BY customer_id ORDER BY counts DESC)
				 FROM temp_cte FULL OUTER JOIN menu ON temp_cte.product_id = menu.product_id;

--6. Which item was purchased first by the customer after they became a member?
WITH temp_cte AS (SELECT mm.customer_id c_id,join_date,order_date,sales.product_id p_id,product_name,
ROW_NUMBER() OVER(PARTITION BY mm.customer_id ORDER BY order_date) AS rnk FROM members mm 
				  INNER JOIN sales ON mm.customer_id = sales.customer_id 
				  INNER JOIN menu ON menu.product_id = sales.product_id
				 WHERE order_date >= join_date  
)
SELECT c_id,p_id,product_name FROM temp_cte
WHERE rnk = 1;

--7. Which item was purchased first by the customer just before they became a member?
WITH temp_cte AS (SELECT mm.customer_id c_id,join_date,order_date,sales.product_id p_id,product_name,
ROW_NUMBER() OVER(PARTITION BY mm.customer_id ORDER BY order_date DESC) AS rnk FROM members mm 
				  INNER JOIN sales ON mm.customer_id = sales.customer_id 
				  INNER JOIN menu ON menu.product_id = sales.product_id
				 WHERE order_date < join_date  
)
SELECT c_id,p_id,product_name FROM temp_cte
WHERE rnk = 1; 


--8. What is the total items and amount spent for each member before they became a member?
SELECT mm.customer_id,COUNT(menu.product_id),SUM(price)
FROM menu INNER JOIN sales ON sales.product_id = menu.product_id 
		  INNER JOIN members mm ON mm.customer_id = sales.customer_id
WHERE order_date<join_date 
GROUP BY mm.customer_id;

--9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH temp_cte AS (SELECT customer_id,s.product_id,price,
				 		CASE WHEN s.product_id = '1' THEN price*20
				 			 ELSE price*10 END AS points
				 FROM menu FULL OUTER JOIN sales s
				 ON menu.product_id = s.product_id)
SELECT customer_id,SUM(points) AS total_points
FROM temp_cte GROUP BY customer_id ORDER BY customer_id;

--10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
SELECT mm.customer_id,SUM(price*20) 
FROM menu FULL OUTER JOIN sales s ON menu.product_id = s.product_id
FULL OUTER JOIN members mm ON mm.customer_id = s.customer_id
WHERE order_date >= join_date AND order_date < '2021-01-31'
GROUP BY mm.customer_id; 

/*
Recreate the following table output using the available data:

customer_id	order_date	product_name	price	member
		A	2021-01-01	curry			15		N
		A	2021-01-01	sushi			10		N
		A	2021-01-07	curry			15		Y
		A	2021-01-10	ramen			12		Y
		A	2021-01-11	ramen			12		Y
		A	2021-01-11	ramen			12		Y
		B	2021-01-01	curry			15		N
..		..			..	..	..
*/
SELECT s.customer_id,s.order_date,menu.product_name,menu.price,
	   CASE WHEN s.order_date >= (join_date) THEN 'Y'
	   ELSE 'N' END AS member
FROM menu FULL OUTER JOIN sales s ON menu.product_id = s.product_id
FULL OUTER JOIN members mm ON mm.customer_id = s.customer_id
order by s.customer_id,s.order_date;

/*
Rank All The Things
Danny also requires further information about the ranking of 
customer products, but he purposely does not need the ranking for 
non-member purchases so he expects null ranking values for the 
records when customers are not yet part of the loyalty program.

customer_id	order_date	product_name	price	member	ranking
		A	2021-01-01		curry		15			N	null
		A	2021-01-01		sushi		10			N	null
		A	2021-01-07		curry		15			Y	1
		A	2021-01-10		ramen		12			Y	2
		A	2021-01-11		ramen		12			Y	3
		A	2021-01-11		ramen		12			Y	3
		B	2021-01-01		curry		15			N	null
		
*/

WITH temp_cte AS (SELECT s.customer_id c_id,s.order_date o_dt,menu.product_name p_name,menu.price price,join_date,
	   CASE WHEN s.order_date >= (join_date) THEN 'Y'
	   ELSE 'N' END AS member
FROM menu FULL OUTER JOIN sales s ON menu.product_id = s.product_id
FULL OUTER JOIN members mm ON mm.customer_id = s.customer_id
order by s.customer_id,s.order_date)
SELECT c_id,o_dt,p_name,price,member,
		CASE WHEN member = 'Y' AND o_dt >= join_date THEN 
				CASE WHEN member = 'Y' AND o_dt >= join_date THEN RANK() OVER(PARTITION BY c_id,member ORDER BY o_dt)
		ELSE NULL END 
		END AS ranking
FROM temp_cte;
