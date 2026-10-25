-- Check duplicate transaction IDs
SELECT COUNT(*) - COUNT(DISTINCT id) AS duplicate_ids
FROM transactions;

-- Check non-positive transaction amounts
SELECT COUNT(*) AS invalid_amounts
FROM transactions
WHERE amount <= 0;

-- Check transactions without matching accounts
SELECT COUNT(*) AS unmatched_transactions
FROM transactions t
LEFT JOIN accounts a ON t.account_id = a.id
WHERE a.id IS NULL;

-- Check inconsistencies in loan payment amounts
SELECT COUNT(*) AS inconsistent_payments
FROM loan_payments
WHERE ABS(amount - principal_paid - interest_paid) > 0.01;

-- Inspect inconsistent loan payment records
SELECT id AS payment_id,
       loan_id,
       amount,
       principal_paid,
       interest_paid,
       ROUND(amount - principal_paid - interest_paid, 2) AS difference
FROM loan_payments
WHERE ABS(amount - principal_paid - interest_paid) > 0.01
ORDER BY ABS(amount - principal_paid - interest_paid) DESC
LIMIT 10;

-- Check transactions recorded before account opening dates
SELECT
    COUNT(*) AS transactions_before_opening
FROM transactions t
JOIN accounts a
    ON t.account_id = a.id
WHERE t.timestamp::date < a.opened_date;

-- Check loan payments recorded before loan start dates
SELECT
    COUNT(*) AS payments_before_loan_start
FROM loan_payments lp
JOIN loans l
    ON lp.loan_id = l.id
WHERE lp.payment_date < l.start_date;

-- Check loans with total principal repaid exceeding original loan amount
SELECT
    l.id AS loan_id,
    l.status,
    l.amount AS original_loan_amount,
    ROUND(SUM(lp.principal_paid), 2) AS total_principal_paid,
    ROUND(SUM(lp.principal_paid) - l.amount, 2) AS excess_principal
FROM loans l
JOIN loan_payments lp
    ON l.id = lp.loan_id
GROUP BY l.id, l.status, l.amount
HAVING SUM(lp.principal_paid) > l.amount
ORDER BY excess_principal DESC;