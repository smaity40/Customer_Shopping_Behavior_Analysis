SELECT * FROM customer;


--q1. what is the total revenue genarete by male vs female customers?
  SELECT gender,SUM(purchase_amount) AS revenue
  FROM customer
  GROUP BY gender;
  
--q2. which customer used a discount but still spent more than the average purchase amount?
   SELECT customer_id,purchase_amount 
   FROM customer
   WHERE discount_applied ='Yes' AND purchase_amount >=( SELECT AVG(purchase_amount) FROM customer);
   
--q3. which are the top 5 products with the higher average review rating?
  SELECT item_purchased, ROUND(AVG(review_rating)::NUMERIC,2) AS average_product_rating
  FROM customer
  GROUP BY item_purchased
  ORDER BY average_product_rating DESC
  LIMIT 5;

--q4.compare the average purchase amounts between standard and express shipping?
  SELECT shipping_type,
  ROUND(AVG(purchase_amount),2)
  FROM customer
  WHERE shipping_type IN ('Express','Standard')
  GROUP BY shipping_type;

--q5.do subscribed customers spend more? compare average spend and total revenue between subscirbers and non-subscribes
  SELECT subscription_status,
  COUNT(customer_id) AS total_customer,
  ROUND(AVG(purchase_amount),2) as average_spend,
  ROUND(SUM(purchase_amount),2) AS total_revenue
  FROM customer
  GROUP BY subscription_status
  ORDER BY total_revenue,average_spend DESC;

--q6.which 5 products have a higher percentages of purchases with discounts applies?
  SELECT item_purchased,COUNT(*),SUM(CASE WHEN discount_applied='Yes' THEN 1 ELSE 0 END),
  
 (100 * SUM(CASE WHEN discount_applied='Yes' THEN 1 ELSE 0 END)/COUNT(*)) AS discount_rate --MAIN FORMULA
  FROM customer
  GROUP BY item_purchased
  ORDER BY discount_rate DESC
  LIMIT 5; 
  
--q7.segment customer into new,returning ,and loyal based on their total 
--number of previous purchases, and show the count of each segment.
 WITH customer_type AS(
SELECT customer_id,previous_purchases,
CASE 
    WHEN previous_purchases =1 THEN 'New'
	WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
	ELSE 'Loyal'
	END AS customer_segment
FROM customer

 )
 SELECT customer_segment,COUNT(*) AS "Number of customer"
 FROM customer_type
 GROUP BY customer_segment;

 --q8.what are the top 3 most purchases product within each category?
 with item_counts AS(
SELECT category,
item_purchased,
COUNT(customer_id)AS total_orders,
ROW_NUMBER() OVER(PARTITION BY category ORDER BY COUNT(customer_id)DESC) AS item_rank
FROM customer
GROUP  BY category,item_purchased
)
SELECT item_rank,category,item_purchased,total_orders
FROM item_counts
WHERE item_rank<=3;

--q9.Are customers who are repeat buyers (more than 5 previous purchases) also likely to subscribe?
SELECT subscription_status,
COUNT(customer_id) AS repeat_buyers
FROM customer
WHERE previous_purchases>5
GROUP BY subscription_status;

--q10.what is the revenue contribution of each age group
SELECT age_group,SUM(purchase_amount) AS revenue
FROM customer
GROUP BY age_group
ORDER BY revenue DESC;

