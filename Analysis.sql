--Apple Sales Project

SELECT *
FROM category;

SELECT *
FROM products;

SELECT *
FROM stores;

SELECT *
FROM sales;

SELECT *
FROM warranty;

--Exploratory Data Analysis(EDA)
SELECT DISTINCT repair_status --4 different status: Rejected, Completed, In progress, Pending
FROM warranty;

SELECT DISTINCT category_name --10 categories
FROM category;

SELECT DISTINCT store_name
FROM stores; --69 distinct stores

SELECT DISTINCT store_id
FROM stores;--75 stores
----checking if there esixts store names that have two store_ids.
SELECT store_name, COUNT(DISTINCT store_id)
FROM stores
GROUP BY store_name
HAVING COUNT(DISTINCT store_id) > 1;---6 stores have two different store ids.

SELECT DISTINCT product_id---89
FROM products;
SELECT DISTINCT product_name ---88 names
FROM products;

SELECT product_name, COUNT(DISTINCT product_id)
FROM products
GROUP BY product_name
HAVING COUNT(DISTINCT product_id) > 1; --HomePod mini has two product ids. different category and launch date.

SELECT COUNT(*)
FROM sales; --1040200 rows

--Improving Query Performance 
EXPLAIN ANALYZE
SELECT* FROM sales
WHERE product_id = 'p-44'---execution time: 96.511ms;

CREATE INDEX sales_product_id ON sales(product_id);

EXPLAIN ANALYZE
SELECT* FROM sales
WHERE product_id = 'p-44';--exeution time: 0.173ms; 

EXPLAIN ANALYZE
SELECT* FROM sales
WHERE store_id = 'ST-31';--execution time:107.042ms,--parallel sequeence scan

CREATE INDEX sales_store_id ON sales(store_id);

EXPLAIN ANALYZE
SELECT* FROM sales
WHERE store_id = 'ST-31'--execution time: 22.328ms,--bitmap index scan

CREATE INDEX sales_sale_date ON sales(sale_date);

---Business Problems

--Q1. Find the number of stores in each country.
SELECT * FROM stores;

SELECT country, 
       COUNT(store_id) as total_stores
FROM stores
GROUP BY country
ORDER BY 2 DESC;-- 2 indicates COUNT(store_id)
------19 countries; US has highest number of stores:15;Australia & China has 7;Japan has 6; Canada has 5.

--Q2. Calculate the total number of units sold by each store.
SELECT s.store_id,
       st.store_name,
	   st.country,
       SUM(quantity) as total_unit_sold
FROM sales as s
JOIN
stores as st ON st.store_id = s.store_id
GROUP BY 1,2,3
ORDER BY 4 DESC;
--Top 5 stores: ST-56-Apple Southland(77795)-Australia, Apple Fukuoka(77787)-Japan, Fifth Ave(77689)-US, 
--Dubai Mall(77571)-UAE, Apple Kurfuerstendamm(77532)-Germany.
--lowest ones are : "Apple Passeig de Gracia", "Apple Causeway Bay", "Apple Piazza Liberty", "Apple Andino", "Apple Champs-Elysees"

--Q3.Identify how many sales occurred in December 2023.
SELECT COUNT(sale_id) as total_sales
FROM sales
WHERE TO_CHAR(sale_date,'MM-YYYY') = '12-2023'; ---18076 sales occured in december 2023

--Q4.Determine how many stores have never had a warranty claim filed.
SELECT COUNT(*) FROM stores
WHERE store_id NOT IN(
                      SELECT DISTINCT store_id
					   FROM sales as s
					   RIGHT JOIN warranty as w
					   ON s.sale_id = w.sale_id
                      );------------0 stores; every stores had warranty claim filed.

--Q5.Calculate the percentage of warranty claims marked as "Rejected"
SELECT ROUND(COUNT(claim_id)/(SELECT COUNT(*)FROM warranty)::numeric * 100,2) as Rejected_percentage
FROM warranty
WHERE repair_status = 'Rejected'; ---- 24.52%

--Q6. Identify which store had the highest total units sold in the last year.
SELECT s.store_id,
       st.store_name,
	   SUM(quantity) as total_unit_sold
FROM sales as s
JOIN
stores as st ON st.store_id = s.store_id
WHERE sale_date >= CURRENT_DATE - INTERVAL '1 year'
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 1; ----Apple Fukuoka (11,396 units sold)

--Q7.Count the number of unique products sold in the last year.
SELECT COUNT(DISTINCT product_id)
FROM sales 
WHERE sale_date >= CURRENT_DATE - INTERVAL '1 year'; ---89 unique products sold in the last year

--Q8. Find the average price of products in each category.
SELECT p.category_id,
       c.category_name,
       ROUND(AVG(p.price)::numeric,2) as avg_price
FROM products as p
JOIN category as c ON p.category_id = c.category_id
Group BY 1,2
ORDER BY 3 DESC;---Cat-3 Tablet has highest average price (1479.50),Cat-9 Smart speaker has lowest average price(734.00)


--Q9.For each store, identify the best-selling day based on highest quantity sold.
SELECT *
FROM (
		SELECT store_id,
		       TO_CHAR(sale_date,'Day')as day_name,
			   SUM(quantity)as total_unit_sold,
			   RANK() OVER (PARTITION BY store_id ORDER BY SUM(quantity)DESC)as rank
		FROM sales
		GROUP BY 1,2
) as t1
WHERE rank = 1;---Tuesday is appears most (14), Wednesday appears least(8)

--Q10.Identify the least selling product in each country for each year based on total units sold.
WITH yearly_sales AS (
    SELECT 
        s.store_id,
        st.country,
        EXTRACT(YEAR FROM s.sale_date) AS sale_year,
        s.product_id,
        SUM(s.quantity) AS total_units_sold
    FROM sales s
    JOIN stores st ON s.store_id = st.store_id
    GROUP BY s.store_id, st.country, sale_year, s.product_id
),
ranked_sales AS (
    SELECT 
        country,
        sale_year,
        product_id,
        SUM(total_units_sold) AS total_units_sold,
        RANK() OVER (PARTITION BY country, sale_year ORDER BY SUM(total_units_sold) ASC) AS rank
    FROM yearly_sales
    GROUP BY country, sale_year, product_id
)
SELECT rs.country, rs.sale_year, rs.product_id, p.product_name, rs.total_units_sold
FROM ranked_sales as rs
JOIN products as p ON rs.product_id = p.product_id
WHERE rank = 1
ORDER BY country, sale_year;

--Q11.Calculate how many warranty claims were filed within 180 days of a product sale.
SELECT COUNT(*)
FROM warranty as w
LEFT JOIN sales as s ON s.sale_id = w.sale_id
WHERE w.claim_date - s.sale_date <=180; --5733

SELECT  -----to explore the list of warranty claims that were filed within 180 days of a product sale.
       w.*,
	   s.sale_date,
	   w.claim_date - s.sale_date as days_after_sale
FROM warranty as w
LEFT JOIN sales as s ON s.sale_id = w.sale_id
WHERE w.claim_date - s.sale_date <=180;

--Q12.Determine how many warranty claims were filed for each products launched in the last two years.
SELECT p.product_name,
	   COUNT(w.claim_id)as num_claim,
	   COUNT(s.sale_id) as num_sales
FROM warranty as w RIGHT JOIN sales as s ON s.sale_id = w.sale_id
JOIN products as p ON p.product_id = s.product_id
WHERE p.launch_date >=CURRENT_DATE - INTERVAL '2 years'
GROUP BY 1;

--Q13.List the months in the last three years where sales exceeded 5,000 units in the USA.
SELECT 
	TO_CHAR(sale_date,'MM-YYYY')as month_year,
	TO_CHAR(sale_date, 'Month') as month_name,
	SUM(s.quantity) as total_unit_sold
FROM sales as s JOIN stores as st ON s.store_id = st.store_id
WHERE st.country = 'United States'
	AND s.sale_date>=CURRENT_DATE - INTERVAL '3 years'
GROUP BY 1,2
HAVING SUM(s.quantity) > 5000;

--Q14.Identify the product category with the most warranty claims filed in the last two years.
SELECT 
	c.category_name,
	COUNT(w.claim_id)as total_claims,
FROM warranty as w LEFT JOIN sales as s ON w.sale_id = s.sale_id
					JOIN products as p ON p.product_id = s.product_id
					JOIN category as c ON c. category_id = p.category_id
WHERE w.claim_date >= CURRENT_DATE - INTERVAL '2 years'
GROUP BY 1
ORDER BY 2 DESC; ---Accessories have most claims; smart speaker is least

--Q15.Determine the percentage chance of receiving warranty claims after each purchase for each country.
SELECT
	country,
	total_unit_sold,
	total_claim,
	ROUND(total_claim/total_unit_sold::numeric*53,2) as chance_of_warranty_claims
FROM
(SELECT 
	st.country,
	SUM(s.quantity) as total_unit_sold,
	COUNT(w.claim_id) as total_claim
FROM sales as s JOIN stores as st ON s.store_id = st.store_id
		   LEFT JOIN warranty as w ON w.sale_id = s.sale_id
GROUP BY 1)as t1
ORDER BY 4 DESC; --Austria has most chance;Spain has least

--Q16.Analyze the year-by-year growth ratio for each store.
WITH yearly_sales AS
(SELECT
	s.store_id,
	st.store_name,
	EXTRACT(YEAR FROM sale_date)as year,
	SUM(s.quantity * p.price) as total_sale
FROM sales as s JOIN products as p ON s.product_id = p.product_id
				JOIN stores as st ON st.store_id = s.store_id
GROUP BY 1,2,3
ORDER BY 2,3),
growth_ratio AS
(SELECT 
	store_name,
	year,
	LAG(total_sale,1) OVER(PARTITION BY store_name ORDER BY year) as last_year_sale,
	total_sale as current_year_sale
FROM yearly_sales)
SELECT
	store_name,
	year,
	last_year_sale,
	current_year_sale,
	ROUND((current_year_sale - last_year_sale)::numeric/last_year_sale::numeric*100,3)as growth_ratio
FROM growth_ratio	
WHERE last_year_sale IS NOT NULL
--Q17.Calculate the correlation between product price and warranty claims for products sold in the last five years, segmented by price range.
SELECT
	CASE
		WHEN p.price < 500 THEN 'Less Expensive Product'
		WHEN p.price BETWEEN 500 AND 1000 THEN 'MID Range Product'
		ELSE 'Expensive Product'
	END as price_segment,
	COUNT(w.claim_id) as total_claims
FROM warranty as w LEFT JOIN sales as s ON w.sale_id = s.sale_id
				   		JOIN products as p ON p.product_id = s.product_id
WHERE claim_date >= CURRENT_DATE - INTERVAL '5 years'
GROUP BY 1;---expensive Products high number of claims; then comes the mid range product; less expensive products has less number of total warranty claims

--Q18.Identify the store with the highest percentage of "Pending" claims relative to total claims filed.
WITH pending AS
(SELECT 
	s.store_id,
	COUNT(w.claim_id)as pending
FROM sales as s RIGHT JOIN warranty as w ON w.sale_id = s.sale_id
WHERE w.repair_status = 'Pending'
GROUP BY 1
),
total_claim AS
(SELECT 
	s.store_id,
	COUNT(w.claim_id)as total_claim
FROM sales as s RIGHT JOIN warranty as w ON w.sale_id = s.sale_id
GROUP BY 1	
)
SELECT 
	tc.store_id,
	st.store_name,
	pe.pending,
	tc.total_claim,
	ROUND(pe.pending::numeric/tc.total_claim::numeric * 100,2) as percentage_pending
FROM pending as pe JOIN total_claim as tc ON pe.store_id = tc.store_id JOIN stores as st ON tc.store_id = st.store_id
ORDER BY 5 DESC; ---pending percentage ranges between 20%-30% across all stores. Apple SoHo has the least(20.64%); Apple Taipei has most(30.07 %)

--Q19.Write a query to calculate the monthly running total of sales for each store over the past four years and compare trends during this period.
WITH monthly_sales AS
(SELECT 
	s.store_id,
	EXTRACT(YEAR FROM sale_date) as year,
	EXTRACT(MONTH FROM sale_date)as month,
	TO_CHAR(s.sale_date,'Month') as month_name,
	SUM(p.price*s.quantity)as revenue
FROM sales as s JOIN products as p ON s.product_id = p.product_id
GROUP BY 1,2,3,4
ORDER BY 1,2,3)
SELECT
	store_id,
	year,
	month_name,
	revenue,
	SUM(revenue) OVER (PARTITION BY store_id ORDER BY year) as running_total
FROM monthly_sales;

--Analyze product sales trends over time, segmented into key periods: from launch to 6 months, 6-12 months, 12-18 months, and beyond 18 months.
SELECT
	p.product_name,
	CASE
		WHEN s.sale_date BETWEEN p.launch_date AND p.launch_DATE + INTERVAL '6 month' THEN '0-6 months'
		WHEN s.sale_date BETWEEN p.launch_date + INTERVAL '6 month' AND p.launch_date + INTERVAL '12 month' THEN '6-12 months'
		WHEN s.sale_date BETWEEN p.launch_date + INTERVAL '12 month' AND p.launch_date + INTERVAL '18 month' THEN '12-18 months'
		ELSE '18 months+'
	END as product_life_cycle,
	SUM(s.quantity) as total_quantity_sold
FROM sales as s JOIN products as p ON s.product_id = p.product_id
GROUP BY 1,2
ORDER BY 1,3 DESC;