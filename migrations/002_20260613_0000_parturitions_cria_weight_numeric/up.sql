-- ============================================================
-- MIGRACIÓN: 2026-06-13 — parturitions.cria_weight a NUMERIC(6,2)
-- ============================================================
--
-- MOTIVO:
--   La columna cria_weight era INT, pero el DTO de registro de parto
--   (RegisterParturitionDto.criaWeight) acepta hasta 2 decimales,
--   igual que el resto de los campos de peso del sistema
--   (ranch_animals.weight, weight_records.weight). Enviar un peso
--   decimal (ej. 35.5) producía un error 500 de Postgres.
--
-- PARA REVERTIR: ejecutar down.sql de esta misma carpeta
-- ============================================================

ALTER TABLE parturitions
    ALTER COLUMN cria_weight TYPE NUMERIC(6,2);
