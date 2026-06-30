-- ============================================================
-- TABLA: countries  [CATÁLOGO — datos fijos del sistema]
-- MÓDULO: Base geográfica
-- ============================================================
-- Países disponibles para el registro de estancias.
-- La jerarquía geográfica es: countries → regions → cities → ranches.
-- ============================================================

CREATE TABLE countries (
    id_country SERIAL,
    name VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (id_country)
);