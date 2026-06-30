-- ==========================================================
-- RESET COMPLETO — elimina todo y recarga desde schema/
-- Usar solo en entornos vacíos o de desarrollo.
-- ==========================================================

DO $$ DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
        EXECUTE 'DROP TABLE IF EXISTS public.' || quote_ident(r.tablename) || ' CASCADE';
    END LOOP;
END $$;

\i schema/init.sql
