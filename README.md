# Retail-Analysis-Using-SQL

An end-to-end SQL analytics project focused on ingesting, sanitizing, and evaluating omnichannel retail transactional data to extract actionable business performance insights.

---

## Overview

This project simulates real-world retail transactional analysis using SQL. It covers:
* Database schema creation and raw data ingestion.
* Data sanitation and cleaning of incomplete records.
* Exploratory Data Analysis (EDA) to map catalog reach and customer demographics.
* Advanced SQL queries addressing key business challenges such as peak operating shifts, high-ticket segments, and customer lifetime value.

---

## Dataset & Pipeline Summary

* **Raw Ingested Records:** 2,000 transactions
* **Data Sanitation:** 13 records purged due to null values across critical attributes (`buyer_age`, `units_sold`, `unit_price`, `cost_of_goods`)
* **Clean Analytical Dataset:** 1,987 completed transactions
* **Distinct Customer Base:** 155 unique buyers
* **Active Product Lines:** Clothing, Beauty, Electronics

---

## Database Schema (PostgreSQL / MySQL)

```sql
CREATE TABLE customer_transactions (
    transaction_id   INT PRIMARY KEY,
    transaction_date DATE,
    transaction_time TIME,
    buyer_id         INT,
    buyer_gender     VARCHAR(10),
    buyer_age        INT,
    product_line     VARCHAR(35),
    units_sold       INT,
    unit_price       FLOAT,
    cost_of_goods    FLOAT,
    net_revenue      FLOAT
);
