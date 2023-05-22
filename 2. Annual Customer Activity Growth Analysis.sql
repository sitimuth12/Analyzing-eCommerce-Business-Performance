--Task 2 (Annual Customer Activity Growth Analysis)
--1. Average Monthly Active User (MAU) by year
WITH tmp AS (SELECT cs.customer_unique_id, o.order_id,
			 		date_part('year', o.order_purchase_timestamp) AS year,
			 		date_part('month', o.order_purchase_timestamp) AS month
	 		 FROM customers_dataset AS cs
			 INNER JOIN orders_dataset AS o
						ON cs.customer_id = o.customer_id),
	 mau AS (SELECT year, round(AVG(total_customer), 0) AS avg_mau
			 FROM (SELECT year, month, 
				   		  COUNT(DISTINCT customer_unique_id) AS total_customer 
				   FROM tmp
				   GROUP BY 1, 2) subq1
			 GROUP BY 1),

--2. Total new customers by year
new_customer AS (SELECT first_order, COUNT(customer_unique_id) AS new_cust
				 FROM (SELECT customer_unique_id, MIN(year) AS first_order
					   FROM tmp
					   GROUP BY 1) AS subq2
				 GROUP BY 1),

--3. The number of customers who make repeat orders by year
repeat_orders AS (SELECT year, COUNT(customer_unique_id) AS repeat_cust
				  FROM (SELECT year, customer_unique_id, COUNT(order_id) AS total_order
		 		  	    FROM tmp
		 		  	    GROUP BY 1, 2) AS subq3
				  WHERE total_order > 1
				  GROUP BY 1
				  ORDER BY 1), 	

--4. Average orders by year
avg_orders AS (SELECT year, ROUND(AVG(total_order), 3) AS avg_order
			   FROM (SELECT year, customer_unique_id, COUNT(order_id) AS total_order
		  			 FROM tmp
		  			 GROUP BY 1, 2) AS subq4
			   GROUP BY 1
			   ORDER BY 1)

--5. Combine all previous results
select m.year, m.avg_mau, nc.new_cust, ro.repeat_cust, ao.avg_order
from mau as m
join new_customer as nc on m.year = nc.first_order
join repeat_orders as ro on m.year = ro.year
join avg_orders as ao on m.year = ao.year;