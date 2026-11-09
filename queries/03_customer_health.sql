-- ============================================================
-- CUSTOMER HEALTH / CHURN RISK
-- Which accounts need proactive outreach?
-- ============================================================

-- Q1. Customers with > 2 tickets in the last 30 days (churn risk)
SELECT c.id, c.name, c.plan,
       COUNT(t.id) AS tickets_last_30d
FROM customers c
JOIN tickets   t ON t.customer_id = c.id
WHERE t.created_at >= DATETIME('now', '-30 days')
GROUP BY c.id
HAVING COUNT(t.id) > 2
ORDER BY tickets_last_30d DESC;

-- Q2. Which error codes generate the most support tickets?
--     → ties support volume to real bugs (Jira escalation input).
SELECT e.error_code,
       COUNT(DISTINCT t.id) AS tickets_touching_that_customer,
       COUNT(DISTINCT e.customer_id) AS affected_customers
FROM events e
JOIN tickets t ON t.customer_id = e.customer_id
WHERE e.error_code IS NOT NULL
  AND t.created_at >= e.created_at
  AND t.created_at <= DATETIME(e.created_at, '+48 hours')
GROUP BY e.error_code
ORDER BY tickets_touching_that_customer DESC;

-- Q3. Customers paying but with zero logins/events in the last 60 days
--     (silent churn risk). Events are our proxy for activity.
SELECT c.id, c.name, s.plan, s.mrr_cents,
       MAX(e.created_at) AS last_event_at
FROM customers     c
JOIN subscriptions s ON s.customer_id = c.id AND s.status = 'active'
LEFT JOIN events   e ON e.customer_id = c.id
GROUP BY c.id
HAVING last_event_at IS NULL
    OR last_event_at < DATETIME('now', '-60 days');