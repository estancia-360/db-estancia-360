-- ============================================================
-- MIGRACIÓN: 2026-08-05 — recuperar contraseña real (código verificado en servidor)
-- ============================================================
--
-- MOTIVO: ver README.md de esta carpeta.
-- ============================================================

ALTER TABLE users
    ADD COLUMN IF NOT EXISTS reset_code_hash VARCHAR(255),
    ADD COLUMN IF NOT EXISTS reset_code_expires_at TIMESTAMP;
