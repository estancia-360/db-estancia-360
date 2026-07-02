-- ============================================================
-- ROLLBACK: 2026-06-30 — ajustes de catálogo, ranch_users y pesos
-- ============================================================

-- 3) columnas de peso: restaurar precisión original
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

-- 2) ranch_users: restaurar columna salary (solo estructura, no datos)
ALTER TABLE ranch_users
    ADD COLUMN IF NOT EXISTS salary DECIMAL(12,2);

-- 1) animal_classes: Torillo → Toro
UPDATE animal_classes
SET name = 'Toro'
WHERE id_animal_class = 10;
