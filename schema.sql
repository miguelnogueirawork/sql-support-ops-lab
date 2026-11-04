-- Support Ops SQL Lab — schema
-- Models a small SaaS with billing + a support desk.

PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS ticket_messages;
DROP TABLE IF EXISTS tickets;
DROP TABLE IF EXISTS events;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS subscriptions;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    id            INTEGER PRIMARY KEY,
    name          TEXT    NOT NULL,
    email         TEXT    NOT NULL,
    signup_date   DATE    NOT NULL,
    plan          TEXT    NOT NULL,          
    country       TEXT
);

CREATE TABLE subscriptions (
    id            INTEGER PRIMARY KEY,
    customer_id   INTEGER NOT NULL REFERENCES customers(id),
    plan          TEXT    NOT NULL,
    status        TEXT    NOT NULL,          
    mrr_cents     INTEGER NOT NULL DEFAULT 0,
    start_date    DATE    NOT NULL,
    end_date      DATE
);

CREATE TABLE payments (
    id                INTEGER PRIMARY KEY,
    customer_id       INTEGER NOT NULL REFERENCES customers(id),
    amount_cents      INTEGER NOT NULL,
    status            TEXT    NOT NULL,      
    stripe_charge_id  TEXT,
    created_at        DATETIME NOT NULL
);

CREATE TABLE tickets (
    id            INTEGER PRIMARY KEY,
    customer_id   INTEGER NOT NULL REFERENCES customers(id),
    subject       TEXT    NOT NULL,
    status        TEXT    NOT NULL,          
    priority      TEXT    NOT NULL,          
    assignee      TEXT,
    created_at    DATETIME NOT NULL,
    resolved_at   DATETIME
);

CREATE TABLE ticket_messages (
    id           INTEGER PRIMARY KEY,
    ticket_id    INTEGER NOT NULL REFERENCES tickets(id),
    author_type  TEXT    NOT NULL,           
    body         TEXT    NOT NULL,
    created_at   DATETIME NOT NULL
);

CREATE TABLE events (
    id           INTEGER PRIMARY KEY,
    customer_id  INTEGER NOT NULL REFERENCES customers(id),
    error_code   TEXT,                       
    endpoint     TEXT,
    created_at   DATETIME NOT NULL
);
