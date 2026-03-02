-- Jersey Premier League Database Schema
-- PostgreSQL initialization script

-- Create users table
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  fpl_team_id VARCHAR(255) UNIQUE,
  is_email_verified BOOLEAN DEFAULT FALSE,
  verification_token VARCHAR(255),
  verification_token_expires TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP,
  deleted_at TIMESTAMP
);

-- Create index on email for faster lookups
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_fpl_team_id ON users(fpl_team_id);
CREATE INDEX IF NOT EXISTS idx_users_verification_token ON users(verification_token);

-- Create announcements table
CREATE TABLE IF NOT EXISTS announcements (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  created_by INT REFERENCES users(id),
  created_at TIMESTAMP DEFAULT NOW(),
  is_active BOOLEAN DEFAULT TRUE
);

-- Create index on created_at for sorting
CREATE INDEX IF NOT EXISTS idx_announcements_created_at ON announcements(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_announcements_is_active ON announcements(is_active);

-- Create admin_whitelist table (for future use if needed)
CREATE TABLE IF NOT EXISTS admin_whitelist (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Create index on email
CREATE INDEX IF NOT EXISTS idx_admin_whitelist_email ON admin_whitelist(email);

-- Create fpl_cache table for optional caching
CREATE TABLE IF NOT EXISTS fpl_cache (
  id SERIAL PRIMARY KEY,
  cache_key VARCHAR(500) UNIQUE NOT NULL,
  data JSONB,
  expires_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Create index on cache_key and expires_at
CREATE INDEX IF NOT EXISTS idx_fpl_cache_key ON fpl_cache(cache_key);
CREATE INDEX IF NOT EXISTS idx_fpl_cache_expires ON fpl_cache(expires_at);

-- Seed admin emails (modify as needed)
INSERT INTO admin_whitelist (email) VALUES
  ('jerseypremierleaguee@gmail.com'),
  ('jpl_admin2@gmail.com'),
  ('jpl_admin3@gmail.com'),
  ('jpl_admin4@gmail.com')
ON CONFLICT (email) DO NOTHING;
