--Task 4 (Analysis of Annual Payment Type Usage)

WITH tmp AS(SELECT op.payment_type, COUNT(o.order_id) AS total_transaction
			FROM order_payments_dataset AS op
			LEFT JOIN orders_dataset AS o on o.order_id = op.order_id
		    GROUP BY 1
		    ORDER BY 2 DESC),
payment_type AS(SELECT payment_type,
       			SUM(CASE WHEN(date_part('year', order_purchase_timestamp)) = 2016 THEN 1 ELSE 0 END) AS year_2016,
       			SUM(CASE WHEN(date_part('year', order_purchase_timestamp)) = 2017 THEN 1 ELSE 0 END) AS year_2017,
       			SUM(CASE WHEN(date_part('year', order_purchase_timestamp)) = 2018 THEN 1 ELSE 0 END) AS year_2018
				FROM order_payments_dataset op
				JOIN orders_dataset o ON op.order_id = o.order_id
				GROUP BY 1
				ORDER BY 4 DESC)

SELECT 	tmp.payment_type, tmp.total_transaction, pt.year_2016, pt.year_2017, pt.year_2018
FROM tmp
JOIN payment_type AS pt ON tmp.payment_type = pt.payment_type