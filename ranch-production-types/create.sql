-- ============================================================
-- TABLA: ranch_production_types
-- MÓDULO: Gestión de Estancias
-- ============================================================
-- Tabla de unión ManyToMany entre ranches y production_types.
-- Define qué rubros productivos tiene habilitados cada estancia.
-- RF-01.4: Toda estancia debe tener al menos un rubro activo.
-- RF-01.5: Los módulos productivos solo operan si su rubro está aquí.
--
-- LÓGICA BACKEND:
--   Antes de permitir cualquier acción de módulo (ej: crear fattening_entry),
--   el backend verifica que el id_production_type correspondiente esté
--   registrado aquí para la estancia del animal. Si no está → rechazar.
-- ============================================================

CREATE TABLE ranch_production_types (
    id_ranch            INT     NOT NULL,
    id_production_type  INT     NOT NULL,
    PRIMARY KEY (id_ranch, id_production_type),
    FOREIGN KEY (id_ranch)           REFERENCES ranches(id_ranch),
    FOREIGN KEY (id_production_type) REFERENCES production_types(id_type)
);
