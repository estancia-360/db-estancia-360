-- ============================================================
-- MIGRACIÓN: 2026-07-05 — animal_exits: agregar local_id
-- ============================================================
--
-- MOTIVO:
--   El módulo Movimientos necesita idempotencia offline en las 3 tablas
--   (movements, movement_animals, animal_exits). Las primeras dos ya
--   tenían local_id desde su creación; animal_exits quedó afuera.
--
-- PARA REVERTIR: ejecutar down.sql de esta misma carpeta
-- ============================================================

ALTER TABLE animal_exits
    ADD COLUMN IF NOT EXISTS local_id VARCHAR(100) UNIQUE;
