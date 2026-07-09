-- ============================================================
-- MIGRACIÓN: 2026-07-07 — animal_breeds: catálogo real de razas
-- ============================================================
--
-- MOTIVO:
--   id_breed=1 estaba cargado como 'VACA', que no es una raza — es el
--   nombre genérico de una hembra bovina adulta. Se corrige a un
--   catálogo real de razas comunes en la ganadería boliviana, agrupadas
--   por función (carne, leche, criollas/mestizas). No es lista cerrada:
--   la estancia puede agregar o desactivar razas propias.
--
-- PARA REVERTIR: ejecutar down.sql de esta misma carpeta
-- ============================================================

UPDATE animal_breeds
SET name = 'Criollo Boliviano'
WHERE id_breed = 1;

INSERT INTO animal_breeds (id_breed, name, is_active) VALUES
(2, 'Nelore', TRUE),
(3, 'Brahman', TRUE),
(4, 'Senepol', TRUE),
(5, 'Sindi', TRUE),
(6, 'Holstein', TRUE),
(7, 'Pardo Suizo', TRUE),
(8, 'Jersey', TRUE),
(9, 'Mestizo', TRUE)
ON CONFLICT (id_breed) DO NOTHING;
