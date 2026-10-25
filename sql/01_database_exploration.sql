-- Phase 1: Database Exploration
-- Check the number of transaction records
SELECT COUNT(*) AS total_transactions
FROM transactions;

-- Count the total number of customers
SELECT COUNT(*) AS total_customers
FROM customers;

-- Count the total number of accounts
SELECT COUNT(*) AS total_accounts
FROM accounts;

-- Calculate the average number of accounts per customer
SELECT
    COUNT(*) * 1.0 / (SELECT COUNT(*) FROM customers) AS avg_accounts_per_customer
FROM accounts;

-- Count the number of accounts held by each customer
SELECT c.id AS customer_id,
       COUNT(a.id) AS account_count
FROM customers c
LEFT JOIN accounts a
ON c.id = a.customer_id
GROUP BY c.id
ORDER BY account_count DESC;

-- Analyse the distribution of account ownership
WITH customer_accounts AS (
    SELECT c.id AS customer_id,
           COUNT(a.id) AS account_count
    FROM customers c
    LEFT JOIN accounts a ON c.id = a.customer_id
    GROUP BY c.id
)
SELECT account_count,
       COUNT(*) AS number_of_customers
FROM customer_accounts
GROUP BY account_count
ORDER BY account_count;
