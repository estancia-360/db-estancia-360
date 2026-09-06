-- Revierte 012_20260906_1714_check_constraints_rangos_y_timestamps_default

ALTER TABLE ranch_pastures
    ALTER COLUMN updated_at DROP DEFAULT,
    ALTER COLUMN created_at DROP DEFAULT;

ALTER TABLE ranch_lots
    ALTER COLUMN updated_at DROP DEFAULT,
    ALTER COLUMN created_at DROP DEFAULT;

ALTER TABLE ranch_pastures
    DROP CONSTRAINT IF EXISTS ranch_pastures_area_hectares_positive;

ALTER TABLE ranch_lots
    DROP CONSTRAINT IF EXISTS ranch_lots_capacity_positive;

ALTER TABLE weight_records
    DROP CONSTRAINT IF EXISTS weight_records_weight_positive;

ALTER TABLE ranch_animals
    DROP CONSTRAINT IF EXISTS ranch_animals_birthdate_not_future;

ALTER TABLE ranch_animals
    DROP CONSTRAINT IF EXISTS ranch_animals_weight_positive;
