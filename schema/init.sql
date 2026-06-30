-- ==========================================================
-- SCHEMA LOAD ORDER
-- Rutas siempre desde la raíz del proyecto. Dependencias primero.
-- ==========================================================

-- geo
\i schema/geo/init.sql

-- catalog
\i schema/catalog/init.sql

-- auth
\i schema/auth/init.sql

-- ranches
\i schema/ranches/init.sql

-- animals
\i schema/animals/init.sql

-- breeding
\i schema/breeding/init.sql

-- rearing
\i schema/rearing/init.sql

-- movements
\i schema/movements/init.sql

-- health
\i schema/health/init.sql

-- fattening
\i schema/fattening/init.sql

-- sync
\i schema/sync/init.sql
