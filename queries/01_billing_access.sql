-- ============================================================
-- BILLING / ACCESS TRIAGE
-- The most common L1/L2 support investigation: "I paid, but I 
-- don't have access" or "my subscription shows the wrong state".
-- ============================================================

-- Q1. Customer paid successfully but subscription is NOT active
--     → the classic "I paid, no access" ticket.
SELECT c.id, c.name, c.email,
       s.status AS sub_status,
       p.amount_cents, p.created_at AS paid_at
FROM customers c
JOIN payments      p ON p.customer_id = c.id AND p.status = 'succeeded'
JOIN subscriptions s ON s.customer_id = c.id
WHERE s.status <> 'active'
ORDER BY p.created_at DESC;

-- Q2. Active subscriptions whose last payment FAILED
--     → ops alert: these will churn or complain next cycle.
SELECT c.id, c.name, s.plan, s.mrr_cents,
       MAX(p.created_at) AS last_payment_at,
       (SELECT status FROM payments
        WHERE customer_id = c.id
        ORDER BY created_at DESC LIMIT 1) AS last_payment_status
FROM customers c
JOIN subscriptions s ON s.customer_id = c.id
JOIN payments      p ON p.customer_id = c.id
WHERE s.status = 'active'
GROUP BY c.id
HAVING last_payment_status = 'failed';

-- Q3. Payments with a NULL stripe_charge_id
--     → data hygiene + reconciliation issue.
SELECT id, customer_id, amount_cents, status, created_at
FROM payments
WHERE stripe_charge_id IS NULL
ORDER BY created_at DESC;

-- Q4. Refunded customers who still have an active subscription
--     → either bad refund or bad subscription state. Investigate.
SELECT c.id, c.name,
       COUNT(p.id) AS refunded_payments,
       s.status    AS current_sub_status
FROM customers c
JOIN payments      p ON p.customer_id = c.id AND p.status = 'refunded'
JOIN subscriptions s ON s.customer_id = c.id
GROUP BY c.id
HAVING s.status = 'active';