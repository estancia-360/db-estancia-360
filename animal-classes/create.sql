-- ============================================================
-- TABLA: animal_classes
-- MÓDULO: Animales — Catálogo de categorías bovinas
-- ============================================================
--
-- DESCRIPCIÓN:
--   Catálogo de las categorías (clases) de bovinos que maneja el sistema.
--   La categoría de cada animal es seleccionada manualmente por el
--   operador al momento del registro o cuando cambia de etapa productiva.
--   Ya no se calcula automáticamente a partir de booleanos.
--
-- CATEGORÍAS (según ANEXO 1 del documento de diseño):
--
--   TERNEROS — animales jóvenes, no destetados, menores de 11 meses
--   ┌─────────────────────────┬─────┐
--   │ Ternera                 │  F  │
--   │ Ternero Macho Entero    │  M  │
--   │ Ternero Macho Castrado  │  M  │
--   └─────────────────────────┴─────┘
--
--   DESTETADOS — animales post-destete, hasta el año de edad
--   ┌─────────────────────────┬─────┐
--   │ Hembra Destetada        │  F  │
--   │ Macho Entero Destetado  │  M  │
--   │ Macho Castrado Destetado│  M  │
--   └─────────────────────────┴─────┘
--
--   ADULTOS — animales de 12 meses o más
--   ┌─────────────────────────┬─────┐
--   │ Vaquilla                │  F  │
--   │ Vaca                    │  F  │
--   │ Hembra Esterilizada     │  F  │
--   │ Toro                    │  M  │
--   │ Novillo                 │  M  │
--   └─────────────────────────┴─────┘
--
-- COLUMNAS:
--   - sex: sexo al que aplica esta categoría (F=Hembra, M=Macho).
--     Permite filtrar opciones en el formulario de registro según el sexo
--     del animal que se está dando de alta.
--   - is_active: permite deshabilitar categorías sin eliminar registros
--     históricos que ya la usen.
-- ============================================================

CREATE TABLE animal_classes (
    id_animal_class INT,
    name            VARCHAR(100) NOT NULL,
    sex             CHAR(1)      NOT NULL CHECK (sex IN ('M', 'F')),
    is_active       BOOLEAN      NOT NULL DEFAULT TRUE,
    PRIMARY KEY (id_animal_class)
);
