-- ============================================================
-- WINDOW FUNCTIONS
-- Genuinely useful for support analytics like time-between-tickets and top-N per group.
-- ============================================================

-- Q1. Rank tickets by priority within each customer
--     → "show me the worst ticket per customer".
SELECT id, customer_id, subject, priority,
       ROW_NUMBER() OVER (
         PARTITION BY customer_id
         ORDER BY CASE priority
                    WHEN 'urgent' THEN 1 WHEN 'high' THEN 2
                    WHEN 'normal' THEN 3 ELSE 4 END
       ) AS rn
FROM tickets;

-- Q2. Time between a customer's consecutive tickets
--     → "is this customer contacting us more often?"
SELECT id, customer_id, created_at,
       LAG(created_at) OVER (PARTITION BY customer_id ORDER BY created_at)
         AS previous_ticket_at,
       ROUND(
         (julianday(created_at)
          - julianday(LAG(created_at) OVER (
              PARTITION BY customer_id ORDER BY created_at))) * 24, 1
       ) AS hours_since_previous
FROM tickets
ORDER BY customer_id, created_at;

-- Q3. Top 3 busiest agents by resolved-ticket count
SELECT * FROM (
  SELECT assignee,
         COUNT(*) AS resolved,
         RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk
  FROM tickets
  WHERE resolved_at IS NOT NULL AND assignee IS NOT NULL
  GROUP BY assignee
)
WHERE rnk <= 3;

-- Q4. Running total of resolved tickets per day (30d)
SELECT day, daily,
       SUM(daily) OVER (ORDER BY day) AS running_total
FROM (
  SELECT DATE(resolved_at) AS day, COUNT(*) AS daily
  FROM tickets
  WHERE resolved_at IS NOT NULL
  GROUP BY day
)
ORDER BY day;