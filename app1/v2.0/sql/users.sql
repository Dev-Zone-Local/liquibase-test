--liquibase formatted sql

--changeset github-copilot:users-001
-- Basic users table (PostgreSQL)
CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    username VARCHAR(50),
    password_hash VARCHAR(255) NOT NULL,
    display_name VARCHAR(100),
    is_email_verified BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_login_at TIMESTAMPTZ
);

-- Enforce unique email
ALTER TABLE users
    ADD CONSTRAINT uq_users_email UNIQUE (email);

-- Helpful indexes
CREATE INDEX IF NOT EXISTS idx_users_username ON users (username);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users (created_at);

--rollback DROP INDEX IF EXISTS idx_users_created_at;
--rollback DROP INDEX IF EXISTS idx_users_username;
--rollback ALTER TABLE users DROP CONSTRAINT IF EXISTS uq_users_email;
--rollback DROP TABLE IF EXISTS users;