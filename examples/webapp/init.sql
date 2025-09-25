-- Initialize the webapp database
CREATE TABLE IF NOT EXISTS visitors (
    id SERIAL PRIMARY KEY,
    ip_address INET,
    user_agent TEXT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS app_metrics (
    id SERIAL PRIMARY KEY,
    metric_name VARCHAR(100),
    metric_value INTEGER,
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert some sample data
INSERT INTO app_metrics (metric_name, metric_value) VALUES 
    ('startup_time', 0),
    ('total_requests', 0),
    ('error_count', 0);
