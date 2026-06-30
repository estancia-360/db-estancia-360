-- ============================================================
-- ROLLBACK: 2026-06-30 — animal_classes id=10: "Toro" → "Torillo"
-- ============================================================

UPDATE animal_classes
SET name = 'Toro'
WHERE id_animal_class = 10;
