-- Calculate transaction amount statistics by type
SELECT type,
    COUNT(*) AS transaction_count,
    ROUND(AVG(amount), 2) AS avg_amount,
    ROUND(STDDEV_SAMP(amount), 2) AS std_amount,
    ROUND(PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY amount)::numeric, 2) AS p95_amount,
    ROUND(MAX(amount), 2) AS max_amount
FROM transactions
GROUP BY type
ORDER BY type;

-- Identify high-value transactions using the 95th percentile
WITH transaction_thresholds AS (
    SELECT type,
        PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY amount) AS p95_amount
    FROM transactions
    GROUP BY type
)
SELECT t.id,
    t.account_id,
    t.type,
    t.amount,
    ROUND(th.p95_amount::numeric, 2) AS p95_threshold
FROM transactions t
JOIN transaction_thresholds th ON t.type = th.type
WHERE t.amount > th.p95_amount
ORDER BY t.amount DESC
LIMIT 20;

-- Compare Z-score and IQR outlier detection by transaction type
WITH transaction_stats AS (
    SELECT
        type,
        AVG(amount) AS avg_amount,
        STDDEV_SAMP(amount) AS std_amount,
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY amount) AS q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY amount) AS q3
    FROM transactions
    GROUP BY type
)
SELECT
    t.type,
    COUNT(*) AS total_transactions,
    COUNT(*) FILTER (
        WHERE ABS(t.amount - s.avg_amount) > 3 * s.std_amount
    ) AS zscore_outliers,
    COUNT(*) FILTER (
        WHERE t.amount < s.q1 - 1.5 * (s.q3 - s.q1)
           OR t.amount > s.q3 + 1.5 * (s.q3 - s.q1)
    ) AS iqr_outliers
FROM transactions t
JOIN transaction_stats s
    ON t.type = s.type
GROUP BY t.type
ORDER BY t.type;