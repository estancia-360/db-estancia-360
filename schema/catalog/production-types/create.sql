-- ============================================================
-- TABLA: production_types  [CATÁLOGO — datos fijos del sistema]
-- MÓDULO: Gestión de Estancias
-- ============================================================
-- Rubros productivos disponibles. Se relaciona con las estancias
-- vía ranch_production_types (ManyToMany). Una estancia puede tener
-- uno o más rubros activos.
--
-- VALORES FIJOS (data.sql):
--   1=Cría    — Módulo reproductivo (breeding_services, parturitions, etc.)
--   2=Recría  — Módulo de crecimiento (weight_records, rearing_selections)
--   3=Engorde — Módulo de terminación (fattening_entries, feed_records)
-- ============================================================

CREATE TABLE production_types (
    id_type SERIAL,
    name VARCHAR(30) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (id_type)
);