-- Catálogo de categorías bovinas (ANEXO 1 — Clasificación de Bovinos)
INSERT INTO animal_classes (id_animal_class, name, sex) VALUES
-- ── TERNEROS (no destetados, < 11 meses) ─────────────────────────────────
(1,  'Ternera',                 'F'),
(2,  'Ternero Macho Entero',    'M'),
(3,  'Ternero Macho Castrado',  'M'),
-- ── DESTETADOS (post-destete, hasta el año) ───────────────────────────────
(4,  'Hembra Destetada',        'F'),
(5,  'Macho Entero Destetado',  'M'),
(6,  'Macho Castrado Destetado','M'),
-- ── ADULTOS (≥ 12 meses) ─────────────────────────────────────────────────
(7,  'Vaquilla',                'F'),
(8,  'Vaca',                    'F'),
(9,  'Hembra Esterilizada',     'F'),
(10, 'Toro',                    'M'),
(11, 'Novillo',                 'M');
