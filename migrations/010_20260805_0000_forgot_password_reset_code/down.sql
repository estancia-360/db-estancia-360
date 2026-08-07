ALTER TABLE users
    DROP COLUMN IF EXISTS reset_code_hash,
    DROP COLUMN IF EXISTS reset_code_expires_at;
