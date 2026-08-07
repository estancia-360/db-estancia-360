-- Revierte 009_20260804_0000_movil_alineacion

ALTER TABLE ranch_animals
    DROP CONSTRAINT IF EXISTS ranch_animals_ranch_code_key;

ALTER TABLE ranch_animals
    ADD CONSTRAINT ranch_animals_code_key UNIQUE (code);

ALTER TABLE fattening_entries
    DROP COLUMN IF EXISTS local_id;

ALTER TABLE health_incidents
    DROP COLUMN IF EXISTS local_id;

ALTER TABLE treatments
    DROP COLUMN IF EXISTS local_id;

ALTER TABLE vaccinations
    DROP COLUMN IF EXISTS local_id;
