-- ============================================================
-- ROLLBACK: 2026-06-30 — columnas de peso a NUMERIC(6,2)
-- ============================================================
--
-- Restaura cada columna a su precisión original previa a esta migración.
-- ============================================================

ALTER TABLE ranch_animals
    ALTER COLUMN weight TYPE NUMERIC(12,2);

ALTER TABLE weight_records
    ALTER COLUMN weight TYPE NUMERIC(8,2);

ALTER TABLE weanings
    ALTER COLUMN weaning_weight TYPE NUMERIC(10,2);

ALTER TABLE rearing_selections
    ALTER COLUMN weight_at_selection TYPE NUMERIC(8,2);

ALTER TABLE fattening_entries
    ALTER COLUMN initial_weight TYPE NUMERIC(8,2);

ALTER TABLE animal_declared_history
    ALTER COLUMN prev_avg_weaning_weight TYPE NUMERIC(10,2);
