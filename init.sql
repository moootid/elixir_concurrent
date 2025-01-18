-- Enable TimescaleDB extension
CREATE EXTENSION IF NOT EXISTS timescaledb;

-- Create a hypertable
CREATE TABLE items (
    id SERIAL PRIMARY KEY,
    item TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Convert the table to a hypertable
-- SELECT create_hypertable('items', 'created_at');
