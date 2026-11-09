# SQL Support Ops Lab

A realistic SaaS support database and a collection of **18 diagnostic SQL queries** designed to solve real-world customer support, billing, and application troubleshooting scenarios.

## 📖 About the Project
This repository simulates a small SaaS company (40 customers, active subscriptions, Stripe payment history, Freshdesk/Jira tickets, and application error logs). 

The goal of this project is to demonstrate how a **Product / Application Support Engineer** uses SQL to investigate customer issues, identify churn risks, and debug data anomalies. It bridges the gap between raw data and customer satisfaction.

## 🗂️ Query Categories (18 Queries Total)
The queries are organized into 5 core support engineering categories:

1. **Billing & Access Triage** (`01_billing_access.sql`): 4 queries to solve "I paid but don't have access" issues, failed payments, and refund leaks.
2. **Ticket Analytics & SLA** (`02_ticket_analytics.sql`): 3 queries for average resolution times, SLA breaches, and agent workloads.
3. **Customer Health & Churn** (`03_customer_health.sql`): 3 queries to identify frustrated customers and silent churn risks.
4. **Data Hygiene & Debugging** (`04_data_hygiene.sql`): 4 queries to find duplicate emails, orphaned records, and corrupted data.
5. **Advanced Analytics (Window Functions)** (`05_window_functions.sql`): 4 queries for ranking, time-between-tickets, and running totals.

## 🗄️ Database Schema
The database consists of 6 relational tables:

- `customers`: User accounts and plans.
- `subscriptions`: Active, canceled, or past_due subscription states.
- `payments`: Successful, failed, and refunded payments (via Stripe).
- `tickets`: Customer support requests with SLA priorities.
- `ticket_messages`: The back-and-forth conversation on tickets.
- `events`: Application error logs (e.g., CORS errors, API timeouts).

## 🔍 Query Highlights

### 1. The "I paid, but I don't have access" Ticket
**File:** [`queries/01_billing_access.sql`](queries/01_billing_access.sql)

**The Problem:** 
A customer pays successfully, but their subscription status is still inactive.

**The Solution:** 
Joins `customers`, `payments`, and `subscriptions` to find users whose payment succeeded but whose subscription is not active.

**Sample Output:**
| id | name | email | sub_status | amount_cents |
|---|---|---|---|---|
| 22 | Customer 22 | user22@example.com | past_due | 19900 |
| 31 | Customer 31 | user31@example.com | canceled | 1900 |

---

### 2. Detecting Churn Risk
**File:** [`queries/03_customer_health.sql`](queries/03_customer_health.sql)

**The Problem:** 
Identifying accounts that are frustrated and likely to cancel their subscription soon.

**The Solution:** 
Uses `GROUP BY` and `HAVING` to find customers who have opened more than 2 support tickets in the last 30 days. 

**Sample Output:**
| id | name | plan | tickets_last_30d |
|---|---|---|---|
| 31 | Customer 31 | enterprise | 4 |
| 22 | Customer 22 | starter | 3 |

---

### 3. Time Between Tickets (Window Functions)
**File:** [`queries/05_window_functions.sql`](queries/05_window_functions.sql)

**The Problem:** 
Identifying if a customer is contacting support multiple times in a row because their issue wasn't resolved the first time.

**The Solution:** 
Uses `LAG()` to calculate the exact number of hours between a customer's consecutive tickets.

**Sample Output (Timeline):**
*   **Ticket #2** (Oct 1, 10:00) → *First contact*
*   **Ticket #5** (Oct 1, 14:00) → *Follow-up (**4.0 hours** since previous)*
*   **Ticket #6** (Oct 5, 09:00) → *New issue (**91.0 hours** since previous)*

## 🛠️ Skills Demonstrated
- **SQL:** Advanced `JOIN`s, `GROUP BY`, Subqueries, CTEs, `CASE` statements, and Window Functions (`ROW_NUMBER`, `RANK`, `LAG`).
- **Data Hygiene:** Writing queries to find duplicate emails, orphaned records, and revenue leaks.
- **Automation:** Python scripting to generate and seed a MySQL/SQLite database.
- **Support Engineering:** Translating customer complaints into diagnostic SQL queries.

## 🚀 How to Run This Project

Since this project uses SQLite, you don't need to install any heavy database servers. The database file (`support.db`) and the Python data generator (`generate_seed.py`) are already included in this repository.

### Option 1: Explore the database interactively (Recommended)
1. Clone the repository:
   `git clone https://github.com/miguelnogueirawork/sql-support-ops-lab.git`
   `cd sql-support-ops-lab`
2. Open the SQLite interactive shell:
   `sqlite3 -header -column support.db`
3. Copy and paste any query from the `queries/` folder directly into the shell. (Don't forget the semicolon `;` at the end to execute!).
4. Type `.quit` to exit the shell.

### Option 2: Run a query directly from the terminal
If you want to run a specific query without entering the interactive shell, you can pass it directly to the SQLite command. 

Here is an example using the first query from `queries/01_billing_access.sql` (finding customers who paid but don't have access):
`sqlite3 -header -column support.db "SELECT c.id, c.name, s.status AS sub_status, p.amount_cents, p.created_at AS paid_at FROM customers c JOIN payments p ON p.customer_id = c.id AND p.status = 'succeeded' JOIN subscriptions s ON s.customer_id = c.id WHERE s.status <> 'active' ORDER BY p.created_at DESC LIMIT 5;"`