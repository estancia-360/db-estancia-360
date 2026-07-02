-- ============================================================
-- MIGRACIÓN: 2026-06-30 — ajustes de catálogo, ranch_users y pesos
-- ============================================================
--
-- Tres cambios pedidos en la misma sesión, agrupados en una sola
-- migración por venir del mismo lote de ajustes:
--
-- 1) animal_classes id=10: "Toro" → "Torillo" (el id no cambia, solo
--    el nombre del registro).
-- 2) ranch_users: eliminar columna salary — nunca se usó en flujos
--    reales del backend (no aparece en ningún DTO de creación/
--    actualización ni en lógica de servicio).
-- 3) Columnas de peso del sistema → NUMERIC(6,2) (máximo 4 dígitos
--    enteros + 2 decimales, hasta 9999.99 kg), para unificar el
--    rango en toda la DB. parturitions.cria_weight ya estaba en
--    NUMERIC(6,2) desde 002_20260613_0000_parturitions_cria_weight_numeric.
--
-- ANTES DE CORRER EL PASO 3: verificar que no haya datos que excedan
--   el nuevo rango (si los hay, el ALTER falla solo y no rompe nada,
--   pero conviene saberlo antes):
--
--   SELECT id_ranch_animal, weight FROM ranch_animals WHERE weight >= 10000;
--   SELECT id_weight, weight FROM weight_records WHERE weight >= 10000;
--   SELECT id_weaning, weaning_weight FROM weanings WHERE weaning_weight >= 10000;
--   SELECT id_selection, weight_at_selection FROM rearing_selections WHERE weight_at_selection >= 10000;
--   SELECT id_entry, initial_weight FROM fattening_entries WHERE initial_weight >= 10000;
--   SELECT id_history, prev_avg_weaning_weight FROM animal_declared_history WHERE prev_avg_weaning_weight >= 10000;
--
-- PARA REVERTIR: ejecutar down.sql de esta misma carpeta
-- ============================================================

-- 1) animal_classes: Toro → Torillo
UPDATE animal_classes
SET name = 'Torillo'
WHERE id_animal_class = 10;

-- 2) ranch_users: eliminar salary
ALTER TABLE ranch_users
    DROP COLUMN IF EXISTS salary;

-- 3) columnas de peso → NUMERIC(6,2)
ALTER TABLE ranch_animals
    ALTER COLUMN weight TYPE NUMERIC(6,2);

ALTER TABLE weight_records
    ALTER COLUMN weight TYPE NUMERIC(6,2);

ALTER TABLE weanings
    ALTER COLUMN weaning_weight TYPE NUMERIC(6,2);

ALTER TABLE rearing_selections
    ALTER COLUMN weight_at_selection TYPE NUMERIC(6,2);

ALTER TABLE fattening_entries
    ALTER COLUMN initial_weight TYPE NUMERIC(6,2);

ALTER TABLE animal_declared_history
    ALTER COLUMN prev_avg_weaning_weight TYPE NUMERIC(6,2);
