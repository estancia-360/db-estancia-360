-- ============================================================
-- TABLA: cities  [CATÁLOGO — datos fijos del sistema]
-- MÓDULO: Base geográfica
-- ============================================================
-- Ciudades / municipios por región. Nivel 3 de la jerarquía geográfica.
-- Una estancia (ranches) pertenece a una ciudad.
-- countries → regions → cities → ranches.
-- ============================================================

CREATE TABLE cities (
    id_city SERIAL,
    id_region INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (id_city),
    FOREIGN KEY (id_region) REFERENCES regions(id_region)
);