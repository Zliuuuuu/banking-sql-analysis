-- Analyse loan portfolio by status
SELECT
    status,
    COUNT(*) AS loan_count,
    ROUND(SUM(amount), 2) AS total_loan_amount,
    ROUND(AVG(amount), 2) AS avg_loan_amount,
    ROUND(AVG(interest_rate), 2) AS avg_interest_rate
FROM loans
GROUP BY status
ORDER BY total_loan_amount DESC;

-- Analyse loan repayment performance by loan status
SELECT
    l.status,
    COUNT(DISTINCT l.id) AS loans_with_payments,
    COUNT(lp.id) AS payment_count,
    ROUND(SUM(lp.amount), 2) AS total_repayments,
    ROUND(SUM(lp.principal_paid), 2) AS total_principal_paid,
    ROUND(SUM(lp.interest_paid), 2) AS total_interest_paid
FROM loans l
LEFT JOIN loan_payments lp
    ON l.id = lp.loan_id
GROUP BY l.status
ORDER BY total_repayments DESC;

-- Analyse loan distribution across bank branches
SELECT
    b.id AS branch_id,
    b.name AS branch_name,
    COUNT(l.id) AS loan_count,
    ROUND(COALESCE(SUM(l.amount), 0), 2) AS total_loan_amount,
    COUNT(l.id) FILTER (
        WHERE l.status = 'defaulted'
    ) AS defaulted_loans,
    ROUND(
        COUNT(l.id) FILTER (
            WHERE l.status = 'defaulted'
        ) * 100.0 / NULLIF(COUNT(l.id), 0),
        2
    ) AS default_rate_pct
FROM branches b
LEFT JOIN loans l
    ON b.id = l.branch_id
GROUP BY b.id, b.name
ORDER BY total_loan_amount DESC;

-- Figure 3: Branch Loan Default Rates
SELECT
    b.name AS branch_name,
    COUNT(l.id) AS loan_count,
    COUNT(l.id) FILTER (
        WHERE l.status = 'defaulted'
    ) AS defaulted_loans,
    ROUND(
        COUNT(l.id) FILTER (
            WHERE l.status = 'defaulted'
        ) * 100.0 / NULLIF(COUNT(l.id), 0),
        2
    ) AS default_rate_pct
FROM branches b
LEFT JOIN loans l
    ON b.id = l.branch_id
GROUP BY b.id, b.name
ORDER BY default_rate_pct DESC NULLS LAST;