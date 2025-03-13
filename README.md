# SQL-APPLE-Sales-Analysis

## Project Overview

This project presents an in-depth SQL analysis of Apple retail sales data, showcasing my ability to manipulate and extract insights from large datasets. The analysis covers sales performance, store operations, product trends, and warranty claim patterns, demonstrating expertise in SQL querying, database indexing, and business intelligence.

![Screenshot (15)](https://github.com/user-attachments/assets/5feb8ab7-af40-476f-9e13-de8bca02437a)


## Dataset Information

The analysis is based on five datasets:

+ Sales: 1,040,200 rows - sales transactions (sale_id, sale_date, store_id, product_id, quantity)

+ Warranty: 30,000 rows - warranty claims (claim_id, claim_date, sale_id, repair_status)

+ Stores: 75 rows - store details (store_id, store_name, city, country)

+ Category: 10 rows - product categories (category_id, category_name)

+ Products: 89 rows - product details (product_id, product_name, category_id, launch_date, price)


## Key Analysis & Insights

### Exploratory Data Analysis (EDA)

+ Identified 10 product categories, 75 distinct stores, and 69 unique store names (6 stores had multiple store IDs).

+ Detected 4 distinct warranty repair statuses: Rejected, Completed, In Progress, Pending.

+ Discovered duplicate product names with different category and launch dates.

### Performance Optimization

+ Created indexes on sales(product_id), sales(store_id), and sales(sale_date), improving query execution time from 96.511ms to 0.173ms.

### Business Questions Answered

#### _Sales & Store Analysis_

+ Identified the top-selling store: Apple Southland (77,795 units sold).

+ Determined that every store had at least one warranty claim.

+ Found that Apple Fukuoka had the highest unit sales in the last year.

+ Determined that Tuesday was the best sales day for most stores.

#### _Product & Pricing Trends_

+ Found that HomePod mini had two product IDs due to different categories and launch dates.

+ Identified the highest and lowest average-priced categories: Tablets ($1479.50) vs. Smart Speakers ($734.00).

+ Discovered that the least-selling product varies by country and year.

#### _Warranty Analysis_

+ Found that 24.52% of claims were rejected.

+ Determined that 5,733 warranty claims were filed within 180 days of purchase.

+ Analyzed correlation between product price and warranty claims: expensive products had the most claims.

+ Identified Austria as the country with the highest warranty claim likelihood.

+ Found that Apple Taipei had the highest percentage of pending claims (30.07%).

#### _Sales Trends & Forecasting_

+ Detected monthly sales trends for the last four years.

+ Analyzed product life cycle sales, classifying sales periods into 0-6 months, 6-12 months, 12-18 months, and beyond 18 months.

## Technical Skills Demonstrated

+ **SQL Joins & Aggregations**: Used complex joins and aggregations to extract meaningful business insights.

+ **Window Functions**: Applied RANK(), LAG(), and PARTITION BY for ranking and trend analysis.

+ **Indexing & Performance Optimization**: Reduced query execution time significantly through strategic indexing.

+ **Date & Time Functions**: Utilized EXTRACT(), TO_CHAR(), and INTERVAL to analyze sales trends over time.

+ **Data Cleaning & Validation**: Identified and addressed duplicate records and data inconsistencies.
