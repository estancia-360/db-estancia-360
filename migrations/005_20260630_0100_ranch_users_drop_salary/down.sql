-- ============================================================
-- ROLLBACK: 2026-06-30 — ranch_users: eliminar columna salary
-- ============================================================
--
-- Restaura solo la estructura (DECIMAL(12,2), nullable). Los valores
-- que tuviera la columna antes del DROP no se recuperan.
-- ============================================================

ALTER TABLE ranch_users
    ADD COLUMN IF NOT EXISTS salary DECIMAL(12,2);
