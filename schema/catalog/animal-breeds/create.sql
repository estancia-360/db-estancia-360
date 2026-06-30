-- ============================================================
-- TABLA: animal_breeds  [CATÁLOGO — gestionado por la estancia]
-- MÓDULO: Animales
-- ============================================================
-- Catálogo de razas bovinas disponibles. Cada animal tiene asignada
-- una raza (ranch_animals.id_breed). Las razas son gestionadas por
-- la estancia (pueden agregar las que usen). Es_active permite
-- desactivar razas sin eliminar el historial.
-- ============================================================

CREATE TABLE animal_breeds (
    id_breed SERIAL,
    name VARCHAR(30) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (id_breed)
);
