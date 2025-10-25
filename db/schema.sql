-- Create the 'users' table in PostgreSQL
-- UUID is used for the primary key (id) for better distribution and security.

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(), -- Generate a unique ID for the user
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL, -- Email must be unique for login
    password_hash VARCHAR(255) NOT NULL, -- Store the hashed password
    fpl_team_id VARCHAR(50), -- Can be NULL until the user sets it up
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Index the email column for faster lookups during login
CREATE UNIQUE INDEX idx_users_email ON users (email);

-- Example of how to add a simple test user (password should be hashed with bcrypt)
-- You would run this command manually after hashing a password like 'password123'
-- INSERT INTO users (name, email, password_hash)
-- VALUES ('Admin User', 'admin@jpl.com', '$2a$12$...');
