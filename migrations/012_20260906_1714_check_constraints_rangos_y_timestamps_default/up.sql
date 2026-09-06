-- ============================================================
-- MIGRACIÓN: 2026-09-06 — CHECK de rangos + DEFAULT en timestamps de lotes/potreros
-- ============================================================
--
-- MOTIVO:
--   Ítems de BUG-10 y BUG-12 de la auditoría QA E2E (AuditoriaQAEstancia360 by claudio,
--   2026-09-03) que no requieren backfill (se verificó contra la DB real: 0 filas violan
--   estos rangos hoy).
--
--   DBI-10/DBI-11: ranch_animals.weight y weight_records.weight aceptaban valores <= 0
--     (ej. -500kg). Se agrega CHECK > 0 (weight es nullable en ranch_animals, NOT NULL en
--     weight_records).
--   DBI-12: ranch_animals.birthdate aceptaba fechas futuras (ej. año 2099). Se agrega
--     CHECK birthdate <= CURRENT_DATE.
--   DBI-13: ranch_lots.capacity aceptaba valores <= 0 (ej. -10). Se agrega CHECK > 0
--     (capacity sigue siendo nullable = sin límite definido, sin cambios ahí).
--   DBI-14: ranch_pastures.area_hectares aceptaba valores <= 0 (ej. -5 hectáreas). Se
--     agrega CHECK > 0.
--   12c: ranch_lots y ranch_pastures son las únicas dos tablas del proyecto sin DEFAULT en
--     created_at/updated_at — una inserción directa (fuera del backend, que hoy setea estos
--     campos a mano) falla. Se agrega DEFAULT CURRENT_TIMESTAMP a ambas columnas en las dos
--     tablas, alineándolas con el resto del schema.
--
-- FUERA DE ESTA MIGRACIÓN (decisiones explícitas):
--   DBI-04 (animal_events.id_user nullable): quedó fuera a pedido explícito — hay 242
--     eventos históricos de mayo 2026 sin id_user (previos a que el código empezara a
--     exigirlo siempre) y no se quiso reatribuir esos registros a un usuario real sin
--     haberlo hecho de verdad. La columna queda nullable.
--   DBI-21 (lote apoyado en potrero de otra estancia): se resuelve a nivel aplicación
--     (RanchLotsService), no acá — mismo patrón que ya se usó para SEC-003/DBI-20.
--
-- PARA REVERTIR: ejecutar down.sql de esta misma carpeta
-- ============================================================

ALTER TABLE ranch_animals
    ADD CONSTRAINT ranch_animals_weight_positive CHECK (weight IS NULL OR weight > 0);

ALTER TABLE ranch_animals
    ADD CONSTRAINT ranch_animals_birthdate_not_future CHECK (birthdate <= CURRENT_DATE);

ALTER TABLE weight_records
    ADD CONSTRAINT weight_records_weight_positive CHECK (weight > 0);

ALTER TABLE ranch_lots
    ADD CONSTRAINT ranch_lots_capacity_positive CHECK (capacity IS NULL OR capacity > 0);

ALTER TABLE ranch_pastures
    ADD CONSTRAINT ranch_pastures_area_hectares_positive CHECK (area_hectares > 0);

ALTER TABLE ranch_lots
    ALTER COLUMN created_at SET DEFAULT CURRENT_TIMESTAMP,
    ALTER COLUMN updated_at SET DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE ranch_pastures
    ALTER COLUMN created_at SET DEFAULT CURRENT_TIMESTAMP,
    ALTER COLUMN updated_at SET DEFAULT CURRENT_TIMESTAMP;
