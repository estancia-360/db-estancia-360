-- ============================================================
-- ROLLBACK: 2026-06-13 — parturitions.cria_weight a NUMERIC(6,2)
-- ============================================================

ALTER TABLE parturitions
    ALTER COLUMN cria_weight TYPE INT
    USING ROUND(cria_weight)::INT;
