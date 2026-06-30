-- ============================================================
-- MIGRACIÓN: 2026-06-30 — animal_classes id=10: "Toro" → "Torillo"
-- ============================================================
--
-- MOTIVO:
--   Corrección de nomenclatura del catálogo de categorías bovinas.
--   El registro id_animal_class=10 quedó cargado como "Toro" y debe
--   ser "Torillo". El id no cambia, solo el nombre.
--
-- PARA REVERTIR: ejecutar down.sql de esta misma carpeta
-- ============================================================

UPDATE animal_classes
SET name = 'Torillo'
WHERE id_animal_class = 10;
