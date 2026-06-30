-- ============================================================
-- MIGRACIÓN: 2026-06-30 — ranch_users: eliminar columna salary
-- ============================================================
--
-- MOTIVO:
--   El campo salary nunca se usó en flujos reales del backend (no
--   aparece en ningún DTO de creación/actualización ni en lógica de
--   servicio). Se elimina del modelo de datos.
--
-- ATENCIÓN: esta migración borra datos existentes en esa columna
--   (si los hubiera). El rollback solo restaura la estructura, no
--   los valores.
--
-- PARA REVERTIR: ejecutar down.sql de esta misma carpeta
-- ============================================================

ALTER TABLE ranch_users
    DROP COLUMN IF EXISTS salary;
