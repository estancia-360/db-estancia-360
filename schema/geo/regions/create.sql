-- ============================================================
-- TABLA: regions  [CATÁLOGO — datos fijos del sistema]
-- MÓDULO: Base geográfica
-- ============================================================
-- Regiones / departamentos por país. Nivel 2 de la jerarquía geográfica.
-- countries → regions → cities → ranches.
-- ============================================================

CREATE TABLE regions (
    id_region SERIAL,
    id_country INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (id_region),
    FOREIGN KEY (id_country) REFERENCES countries(id_country)
);