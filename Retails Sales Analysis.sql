-- ====================================================================
-- PROJECT: Omnichannel Retail Transaction Analysis & Customer Insights
-- DATABASE: PostgreSQL / MySQL Compatible
-- PURPOSE: Ingestion verification, data sanitation, KPI metrics, & cohort behavior
-- ====================================================================

-- Step 1: Initial Ingestion Verification
SELECT * FROM customer_transactions 
LIMIT 20;

SELECT COUNT(*) AS total_records_ingested 
FROM customer_transactions;

-- Step 2: Data Sanitation & Missing Value Handling
-- Inspect records with incomplete critical attributes
SELECT * 
FROM customer_transactions
WHERE transaction_date IS NULL 
   OR transaction_time IS NULL 
   OR buyer_id IS NULL 
   OR buyer_gender IS NULL 
   OR buyer_age IS NULL 
   OR product_line IS NULL 
   OR units_sold IS NULL 
   OR unit_price IS NULL 
   OR cost_of_goods IS NULL;

-- Purge anomalous records to preserve analytical integrity
DELETE FROM customer_transactions
WHERE transaction_date IS NULL 
   OR transaction_time IS NULL 
   OR buyer_id IS NULL 
   OR buyer_gender IS NULL 
   OR buyer_age IS NULL 
   OR product_line IS NULL 
   OR units_sold IS NULL 
   OR unit_price IS NULL 
   OR cost_of_goods IS NULL;


-- Step 3: High-Level Exploratory Data Analysis (EDA)
-- Gross completed transactions
SELECT COUNT(*) AS total_completed_transactions 
FROM customer_transactions;

-- Unique customer footprint
SELECT COUNT(DISTINCT buyer_id) AS distinct_customer_base 
FROM customer_transactions;

-- Distinct active product lines
SELECT DISTINCT product_line AS active_catalog_categories 
FROM customer_transactions;


-- Step 4: Strategic Business Performance Queries

-- Q1: Audit specific single-day sales volume (Audit date: 2022-11-05)
SELECT 
    transaction_id,
    buyer_id,
    product_line,
    net_revenue
FROM customer_transactions
WHERE transaction_date = '2022-11-05';

-- Q2: High-volume inventory clearance in 'Clothing' (Nov 2022, Units >= 4)
SELECT 
    transaction_id,
    buyer_id,
    units_sold,
    net_revenue
FROM customer_transactions
WHERE product_line = 'Clothing' 
  AND units_sold >= 4 
  AND TO_CHAR(transaction_date, 'YYYY-MM') = '2022-11';

-- Q3: Category-wise gross revenue breakdown
SELECT 
    product_line, 
    SUM(net_revenue) AS gross_category_revenue
FROM customer_transactions
GROUP BY product_line
ORDER BY gross_category_revenue DESC;

-- Q4: Demographic benchmark (Average buyer age in 'Beauty')
SELECT 
    ROUND(AVG(buyer_age), 2) AS mean_customer_age
FROM customer_transactions
WHERE product_line = 'Beauty';

-- Q5: High-value transaction threshold analysis (Revenue >= 1000)
SELECT 
    transaction_id,
    buyer_id,
    product_line,
    net_revenue
FROM customer_transactions
WHERE net_revenue >= 1000
ORDER BY net_revenue DESC;

-- Q6: Category demand distribution across gender segments
SELECT 
    product_line,
    buyer_gender,
    COUNT(transaction_id) AS transaction_volume
FROM customer_transactions
GROUP BY product_line, buyer_gender
ORDER BY product_line, buyer_gender;

-- Q7: Peak revenue month by annual cycle (Using Dense Window Ranking)
WITH monthly_revenue_aggregated AS (
    SELECT 
        EXTRACT(YEAR FROM transaction_date) AS fiscal_year,
        EXTRACT(MONTH FROM transaction_date) AS calendar_month,
        ROUND(AVG(net_revenue), 2) AS average_ticket_size,
        DENSE_RANK() OVER (
            PARTITION BY EXTRACT(YEAR FROM transaction_date) 
            ORDER BY AVG(net_revenue) DESC
        ) AS performance_tier
    FROM customer_transactions
    GROUP BY 1, 2
)
SELECT 
    fiscal_year,
    calendar_month,
    average_ticket_size
FROM monthly_revenue_aggregated
WHERE performance_tier = 1;

-- Q8: Customer lifetime value (Top 5 revenue-generating accounts)
SELECT 
    buyer_id, 
    SUM(net_revenue) AS aggregate_spend
FROM customer_transactions
GROUP BY buyer_id
ORDER BY aggregate_spend DESC
LIMIT 5;

-- Q9: Product line reach (Unique active accounts per category)
SELECT 
    product_line,
    COUNT(DISTINCT buyer_id) AS unique_purchasers
FROM customer_transactions
GROUP BY product_line
ORDER BY unique_purchasers DESC;

-- Q10: Operational peak-hour order distribution (Shift breakdown)
WITH shift_classified_orders AS (
    SELECT 
        transaction_id,
        CASE 
            WHEN EXTRACT(HOUR FROM transaction_time) < 12 THEN 'Morning Peak (<12 PM)'
            WHEN EXTRACT(HOUR FROM transaction_time) BETWEEN 12 AND 17 THEN 'Afternoon Rush (12-5 PM)'
            ELSE 'Evening Drive (>5 PM)'
        END AS operating_window
    FROM customer_transactions
)
SELECT 
    operating_window,
    COUNT(transaction_id) AS order_throughput
FROM shift_classified_orders
GROUP BY operating_window
ORDER BY order_throughput DESC;
