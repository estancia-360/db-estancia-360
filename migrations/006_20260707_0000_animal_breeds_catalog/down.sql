-- ============================================================
-- ROLLBACK: 2026-07-07 — animal_breeds: catálogo real de razas
-- ============================================================

DELETE FROM animal_breeds WHERE id_breed IN (2, 3, 4, 5, 6, 7, 8, 9);

UPDATE animal_breeds
SET name = 'VACA'
WHERE id_breed = 1;
