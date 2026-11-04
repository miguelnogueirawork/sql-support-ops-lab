# generate_seed.py — run once to generate seed.sql
import random
import datetime as dt

random.seed(42) # Keeps the data the same every time you run it
NOW = dt.datetime(2026, 1, 15, 12, 0, 0)
PLANS = ["free", "starter", "pro", "enterprise"]
COUNTRIES = ["PT", "US", "BR", "ES", "GB", "DE"]
STATUSES = ["open", "pending", "resolved", "closed"]
PRIORITIES = ["low", "normal", "high", "urgent"]
ERRORS = ["CORS_ERROR", "500_DB_TIMEOUT", "INVALID_API_KEY", "RATE_LIMIT", "SSL_EXPIRED", None]
ENDPOINTS = ["/api/v1/orders", "/api/v1/auth", "/api/v1/upload", "/api/v1/billing"]

def rand_date(days_ago_max=365):
    return NOW - dt.timedelta(days=random.randint(0, days_ago_max), hours=random.randint(0, 23))

lines = ["PRAGMA foreign_keys = ON;"]

# 1. Customers
for cid in range(1, 41):
    name = f"Customer {cid}"
    email = f"user{cid}@example.com"
    if cid % 17 == 0: # Duplicate email on purpose for data hygiene queries
        email = "user1@example.com"
    signup = rand_date(700).date()
    plan = random.choice(PLANS)
    country = random.choice(COUNTRIES)
    lines.append(f"INSERT INTO customers VALUES ({cid}, '{name}', '{email}', '{signup}', '{plan}', '{country}');")

# 2. Subscriptions
for sid, cid in enumerate(range(1, 41), start=1):
    plan = random.choice(PLANS)
    status = random.choices(["active", "past_due", "canceled"], [0.7, 0.15, 0.15])[0]
    mrr = random.choice([0, 1900, 4900, 19900]) if plan != "free" else 0
    start = rand_date(600).date()
    end = "NULL" if status == "active" else f"'{rand_date(90).date()}'"
    lines.append(f"INSERT INTO subscriptions VALUES ({sid}, {cid}, '{plan}', '{status}', {mrr}, '{start}', {end});")

# 3. Payments
pid = 1
for cid in range(1, 41):
    for _ in range(random.randint(3, 8)):
        amount = random.choice([0, 1900, 4900, 19900])
        status = random.choices(["succeeded", "failed", "refunded"], [0.8, 0.15, 0.05])[0]
        stripe = f"'ch_{pid:06d}'" if status == "succeeded" else "NULL"
        created = rand_date(400)
        lines.append(f"INSERT INTO payments VALUES ({pid}, {cid}, {amount}, '{status}', {stripe}, '{created:%Y-%m-%d %H:%M:%S}');")
        pid += 1

# 4. Tickets
tid = 1
for cid in range(1, 41):
    for _ in range(random.randint(1, 5)):
        status = random.choices(STATUSES, [0.2, 0.15, 0.4, 0.25])[0]
        priority = random.choice(PRIORITIES)
        assignee = random.choice(["ana", "bruno", "carla", "david", "eve", "NULL"])
        created = rand_date(200)
        resolved = "NULL"
        if status in ("resolved", "closed"):
            resolved = f"'{created + dt.timedelta(hours=random.randint(1, 120)):%Y-%m-%d %H:%M:%S}'"
        subject = random.choice(["Can't log in", "Payment failed", "API returning 500", "SSL certificate warning", "CORS error on upload", "Refund request", "Data not syncing"])
        lines.append(f"INSERT INTO tickets VALUES ({tid}, {cid}, '{subject}', '{status}', '{priority}', {assignee if assignee=='NULL' else repr(assignee)}, '{created:%Y-%m-%d %H:%M:%S}', {resolved});")
        tid += 1

# 5. Ticket Messages
mid = 1
for t in range(1, tid):
    for _ in range(random.randint(1, 3)):
        author = random.choice(["customer", "agent"])
        ts = rand_date(200)
        lines.append(f"INSERT INTO ticket_messages VALUES ({mid}, {t}, '{author}', 'Message body', '{ts:%Y-%m-%d %H:%M:%S}');")
        mid += 1

# 6. Events (App errors)
for eid in range(1, 301):
    cid = random.randint(1, 40)
    code = random.choice(ERRORS)
    code_sql = "NULL" if code is None else f"'{code}'"
    endpoint = random.choice(ENDPOINTS)
    ts = rand_date(120)
    lines.append(f"INSERT INTO events VALUES ({eid}, {cid}, {code_sql}, '{endpoint}', '{ts:%Y-%m-%d %H:%M:%S}');")

with open("seed.sql", "w", encoding="utf-8") as f:
    f.write("\n".join(lines) + "\n")

print("Successfully wrote seed.sql!")