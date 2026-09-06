-- Revierte 011_20260906_1648_bug04_bug10_ranch_animals_local_id_users_unique

DROP INDEX IF EXISTS uq_users_ci_active;

DROP INDEX IF EXISTS uq_users_email_active;

ALTER TABLE ranch_animals
    DROP CONSTRAINT IF EXISTS ranch_animals_ranch_local_id_key;

ALTER TABLE ranch_animals
    ADD CONSTRAINT ranch_animals_local_id_key UNIQUE (local_id);
