-- Analyse transaction volume and amount by type
SELECT type,
       COUNT(*) AS transaction_count,
       ROUND(SUM(amount), 2) AS total_amount,
       ROUND(AVG(amount), 2) AS avg_amount
FROM transactions
GROUP BY type
ORDER BY transaction_count DESC;

-- Analyse monthly transaction trends
SELECT DATE_TRUNC('month', timestamp)::date AS month,
       type,
       COUNT(*) AS transaction_count,
       ROUND(SUM(amount), 2) AS total_amount
FROM transactions
GROUP BY month, type
ORDER BY month, type;

-- Identify the 10 most active accounts
SELECT a.id AS account_id,
       a.type AS account_type,
       COUNT(t.id) AS transaction_count,
       ROUND(SUM(t.amount), 2) AS total_amount
FROM accounts a
JOIN transactions t ON a.id = t.account_id
GROUP BY a.id, a.type
ORDER BY transaction_count DESC
LIMIT 10;

-- Analyse transaction activity across accounts
WITH account_activity AS (
    SELECT a.id AS account_id,
           COUNT(t.id) AS transaction_count
    FROM accounts a
    LEFT JOIN transactions t ON a.id = t.account_id
    GROUP BY a.id
)
SELECT MIN(transaction_count) AS min_transactions,
       MAX(transaction_count) AS max_transactions,
       ROUND(AVG(transaction_count), 2) AS avg_transactions,
       ROUND(STDDEV_SAMP(transaction_count), 2) AS std_transactions
FROM account_activity;

-- Calculate running net cash flow for each account
WITH signed_transactions AS (
    SELECT
        id,
        account_id,
        timestamp,
        type,
        amount,
        CASE
            WHEN type IN ('deposit', 'interest') THEN amount
            WHEN type IN ('withdrawal', 'fee') THEN -amount
            ELSE 0
        END AS net_amount
    FROM transactions
)
SELECT
    account_id,
    timestamp,
    type,
    amount,
    net_amount,
    SUM(net_amount) OVER (
        PARTITION BY account_id
        ORDER BY timestamp, id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_net_flow
FROM signed_transactions
ORDER BY account_id, timestamp, id
LIMIT 30;