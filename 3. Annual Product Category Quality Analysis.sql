--Task 3 (Annual Product Category Quality Analysis)
--1. Revenue by year
WITH tmp AS (SELECT o.order_status,
					o.order_purchase_timestamp,
					p.product_category_name AS product,
					(oi.price + oi.freight_value) AS revenue,
			 		date_part('year', o.order_purchase_timestamp) AS year
			 FROM orders_dataset AS o
			 LEFT JOIN order_items_dataset AS oi
			 ON o.order_id = oi.order_id
			 LEFT JOIN product_dataset AS p
			 ON oi.product_id = p.product_id),
annual_revenue AS (SELECT year, ROUND(SUM(revenue)) AS total_revenue
				   FROM tmp
				   WHERE order_status = 'delivered' AND order_purchase_timestamp IS NOT NULL
				   GROUP BY 1
				   ORDER BY 1),

--2. Total canceled orders by year
canceled_order AS (SELECT year, COUNT(order_status) AS total_canceled
				   FROM tmp
				   WHERE order_status = 'canceled'
				   GROUP BY 1
				   ORDER BY 1),

--3. Top revenue product by year
top_product AS (SELECT year, top_product, top_revenue_product
				FROM (SELECT year, product AS top_product, ROUND(SUM(revenue)) AS top_revenue_product,
					  RANK() OVER (PARTITION BY year ORDER BY SUM(revenue) DESC) AS ranking
					  FROM tmp
					  WHERE order_status = 'delivered'
					  GROUP BY 1, 2) AS revenue_product
				WHERE ranking = 1),

--4. Top canceled product orders by year
top_cancelled_product AS (SELECT year, canceled_product, top_canceled_product
						  FROM (SELECT year, product AS canceled_product, COUNT(order_status) AS top_canceled_product,
								RANK() OVER (PARTITION BY year ORDER BY COUNT(order_status) DESC) AS ranking
								FROM tmp
								WHERE order_status = 'canceled' AND product IS NOT NULL
								GROUP BY 1, 2) AS top_canceled
						  WHERE ranking = 1)
						  
--5. Combine all previous results						  
SELECT ar.year, ar.total_revenue, co.total_canceled, tp.top_product, 
	tp.top_revenue_product, tcp.canceled_product, tcp.top_canceled_product
FROM annual_revenue AS ar
JOIN canceled_order AS co ON ar.year = co.year
JOIN top_product AS tp ON ar.year = tp.year
JOIN top_cancelled_product AS tcp ON ar.year = tcp.year