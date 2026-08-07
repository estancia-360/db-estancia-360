-- ============================================================
-- MIGRACIÓN: 2026-08-04 — alineación móvil: local_id faltantes + code por estancia
-- ============================================================
--
-- MOTIVO:
--   Reajuste grande de la app móvil para que quede alineada con el backend real.
--   Dos cambios de schema necesarios para eso:
--
--   1. local_id en vaccinations/treatments/health_incidents/fattening_entries:
--      estas 4 tablas no tenían idempotencia offline (a diferencia del resto del
--      proyecto, que sí usa local_id en el patrón de sync batch). Sin esto, un
--      reintento de sync por fallo de red duplica el registro.
--
--   2. ranch_animals.code pasa de UNIQUE global a UNIQUE(id_ranch, code):
--      RN-05 siempre documentó "único e irrepetible dentro de la estancia", pero
--      el constraint real era global — dos estancias distintas no podían usar el
--      mismo código de caravana. Se alinea el constraint a la regla documentada.
--
-- PARA REVERTIR: ejecutar down.sql de esta misma carpeta
-- ============================================================

ALTER TABLE vaccinations
    ADD COLUMN IF NOT EXISTS local_id VARCHAR(100) UNIQUE;

ALTER TABLE treatments
    ADD COLUMN IF NOT EXISTS local_id VARCHAR(100) UNIQUE;

ALTER TABLE health_incidents
    ADD COLUMN IF NOT EXISTS local_id VARCHAR(100) UNIQUE;

ALTER TABLE fattening_entries
    ADD COLUMN IF NOT EXISTS local_id VARCHAR(100) UNIQUE;

ALTER TABLE ranch_animals
    DROP CONSTRAINT IF EXISTS ranch_animals_code_key;

ALTER TABLE ranch_animals
    ADD CONSTRAINT ranch_animals_ranch_code_key UNIQUE (id_ranch, code);
