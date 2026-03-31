-- ==========================================================
-- DROP ALL TABLES
-- ==========================================================
DO $$ DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
        EXECUTE 'DROP TABLE IF EXISTS public.' || quote_ident(r.tablename) || ' CASCADE';
    END LOOP;
END $$;

\i countries/init.sql
\i regions/init.sql
\i cities/init.sql
\i production-types/init.sql
\i productive-statuses/init.sql
\i ranch-roles/init.sql
\i roles/init.sql
\i users/init.sql
\i ranches/init.sql
\i ranch-production-types/init.sql
\i ranch-users/init.sql
\i animal-breeds/init.sql
\i animal-statuses/init.sql
\i ranch-pastures/init.sql
\i ranch-lots/init.sql
\i ranch-animals/init.sql
\i event-types/init.sql
\i animal-events/init.sql

-- cria
\i animal-declared-history/init.sql
\i breeding-services/init.sql
\i gestation-diagnoses/init.sql
\i parturitions/init.sql
\i weanings/init.sql

-- recria
\i weight-records/init.sql
\i rearing-selections/init.sql

-- movimientos
\i animal-purchases/init.sql
\i animal-sales/init.sql
\i animal-transfers/init.sql
\i animal-exits/init.sql

-- sanidad
\i vaccinations/init.sql
\i treatments/init.sql
\i health-incidents/init.sql

-- engorde
\i fattening-entries/init.sql
\i feed-records/init.sql