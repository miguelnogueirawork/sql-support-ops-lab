-- ============================================================
-- TICKET ANALYTICS
-- SLA, triage, workload. Ties to Freshdesk/Help Scout/Jira.
-- ============================================================

-- Q1. Average resolution time (hours) by priority
SELECT priority,
       COUNT(*) AS resolved_tickets,
       ROUND(AVG((julianday(resolved_at) - julianday(created_at)) * 24), 1)
         AS avg_resolution_hours
FROM tickets
WHERE resolved_at IS NOT NULL
GROUP BY priority
ORDER BY CASE priority
           WHEN 'urgent' THEN 1 WHEN 'high' THEN 2
           WHEN 'normal' THEN 3 ELSE 4 END;

-- Q2. SLA breaches — urgent > 4h, high > 24h, normal > 72h
SELECT id, customer_id, subject, priority, created_at, resolved_at
FROM tickets
WHERE resolved_at IS NOT NULL
  AND (
    (priority = 'urgent' AND (julianday(resolved_at)-julianday(created_at))*24 > 4)
 OR (priority = 'high'   AND (julianday(resolved_at)-julianday(created_at))*24 > 24)
 OR (priority = 'normal' AND (julianday(resolved_at)-julianday(created_at))*24 > 72)
  )
ORDER BY priority, created_at;

-- Q3. Open ticket volume per assignee (workload)
SELECT COALESCE(assignee, 'unassigned') AS assignee,
       COUNT(*) AS open_tickets
FROM tickets
WHERE status IN ('open', 'pending')
GROUP BY assignee
ORDER BY open_tickets DESC;