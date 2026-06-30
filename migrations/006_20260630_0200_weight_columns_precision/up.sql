-- ============================================================
-- MIGRACIÓN: 2026-06-30 — columnas de peso a NUMERIC(6,2)
-- ============================================================
--
-- MOTIVO:
--   Unificar todas las columnas de peso del sistema al mismo rango:
--   máximo 4 dígitos enteros + 2 decimales (hasta 9999.99 kg).
--   parturitions.cria_weight ya estaba en NUMERIC(6,2) desde la
--   migración 2026-06-13_parturitions-cria-weight-numeric.
--
-- ANTES DE CORRER: verificar que no haya datos que excedan el nuevo
--   rango (si los hay, el ALTER falla solo y no rompe nada, pero
--   conviene saberlo antes). Correr:
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
