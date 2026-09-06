-- ============================================================
-- MIGRACIÓN: 2026-09-06 — local_id por estancia + unicidad real de email/ci
-- ============================================================
--
-- MOTIVO:
--   Dos hallazgos de la auditoría QA E2E (AuditoriaQAEstancia360 by claudio, 2026-09-03):
--
--   1. BUG-04: ranch_animals.local_id era UNIQUE global. Un local_id repetido entre dos
--      estancias distintas (colisión de UUID generado offline, o el mismo valor reenviado
--      por error) hacía que la segunda estancia "encontrara" el registro de la primera en
--      el chequeo de idempotencia del sync y respondiera éxito sin haber guardado nada
--      propio, de forma silenciosa. Pasa a ser único por estancia (id_ranch, local_id).
--      Sin riesgo de datos: al ser único global antes, no puede haber dos filas con el
--      mismo local_id ya en la tabla, así que no hace falta backfill.
--
--   2. BUG-10: users.email y users.ci solo se validaban como únicos a nivel aplicación
--      (chequeo previo al INSERT) — sin constraint real en DB, una condición de carrera
--      (dos registros simultáneos) podía colar dos usuarios activos con el mismo email/ci.
--      Los índices son PARCIALES (solo is_deleted=false) a propósito, para no romper el
--      flujo ya existente de reusar el email/ci de una cuenta previamente borrada lógicamente.
--
-- ADVERTENCIA:
--   Si ya existen usuarios activos duplicados por email o ci en esta DB (podría haber pasado
--   antes de este fix, aunque es poco probable), el CREATE UNIQUE INDEX de abajo va a fallar
--   señalando el valor repetido — hay que resolver el duplicado (borrar/editar) antes de
--   reintentar la migración.
--
-- PARA REVERTIR: ejecutar down.sql de esta misma carpeta
-- ============================================================

ALTER TABLE ranch_animals
    DROP CONSTRAINT IF EXISTS ranch_animals_local_id_key;

ALTER TABLE ranch_animals
    ADD CONSTRAINT ranch_animals_ranch_local_id_key UNIQUE (id_ranch, local_id);

CREATE UNIQUE INDEX IF NOT EXISTS uq_users_email_active ON users (email) WHERE is_deleted = false;

CREATE UNIQUE INDEX IF NOT EXISTS uq_users_ci_active ON users (ci) WHERE is_deleted = false;
