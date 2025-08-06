-- Create the loadtest table
CREATE TABLE loadtest (
    id SERIAL PRIMARY KEY,              -- Unique identifier for each row
    name VARCHAR(255) NOT NULL,         -- Random text column
    value INTEGER NOT NULL,             -- Integer value for testing filters
    created_at TIMESTAMP DEFAULT NOW(), -- Automatically populated with the current timestamp
    updated_at TIMESTAMP DEFAULT NOW()  -- Automatically updated when rows are modified
);

-- Create an index to speed up queries
CREATE INDEX idx_loadtest_value ON loadtest(value);


-- Create a function to update the "updated_at" column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the trigger
CREATE TRIGGER set_updated_at
BEFORE UPDATE ON loadtest
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();


-- Insert sample data into the loadtest table
DO $$
BEGIN
    FOR i IN 1..10000 LOOP
        INSERT INTO loadtest (name, value)
        VALUES (
            md5(random()::text),      -- Random string
            trunc(random() * 1000)   -- Random integer between 0 and 999
        );
    END LOOP;
END $$;


CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

SELECT * FROM pg_available_extensions WHERE name = 'pg_stat_statements';
SELECT * FROM pg_extension;


SELECT calls, total_exec_time, mean_exec_time, query
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 10;

SHOW transaction_read_only;

SET TRANSACTION READ WRITE;
CREATE EXTENSION pg_stat_statements;