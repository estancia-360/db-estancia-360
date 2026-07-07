-- ============================================================
-- ROLLBACK: 2026-07-05 — animal_exits: agregar local_id
-- ============================================================

ALTER TABLE animal_exits
    DROP COLUMN IF EXISTS local_id;
