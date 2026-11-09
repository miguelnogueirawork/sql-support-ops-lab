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