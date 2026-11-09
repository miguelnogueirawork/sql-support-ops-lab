-- ============================================================
-- DATA HYGIENE / DEBUGGING
-- The queries support engineers run when the app "acts weird".
-- ============================================================

-- Q1. Duplicate customer emails (import / sync bugs)
SELECT email, COUNT(*) AS n, GROUP_CONCAT(id) AS customer_ids
FROM customers
GROUP BY email
HAVING COUNT(*) > 1;

-- Q2. Orphaned tickets (foreign key should prevent this, but imported data?)
SELECT t.id, t.customer_id, t.subject
FROM tickets t
LEFT JOIN customers c ON c.id = t.customer_id
WHERE c.id IS NULL;

-- Q3. Tickets resolved BEFORE they were created (clock skew / bad import)
SELECT id, created_at, resolved_at
FROM tickets
WHERE resolved_at IS NOT NULL AND resolved_at < created_at;

-- Q4. Active subscriptions with MRR = 0 on paid plans
--     → revenue leak or data bug. Investigate.
SELECT s.id, s.customer_id, s.plan, s.mrr_cents
FROM subscriptions s
WHERE s.status = 'active'
  AND s.plan IN ('starter', 'pro', 'enterprise')
  AND s.mrr_cents = 0;