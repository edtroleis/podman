-- Initialize database with sample data

-- Create a simple table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO users (username, email) VALUES 
    ('john_doe', 'john@example.com'),
    ('jane_smith', 'jane@example.com'),
    ('bob_wilson', 'bob@example.com')
ON CONFLICT (username) DO NOTHING;

-- Create an index
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- Grant permissions to the application user
GRANT SELECT, INSERT, UPDATE, DELETE ON users TO appuser;
GRANT USAGE, SELECT ON SEQUENCE users_id_seq TO appuser;
