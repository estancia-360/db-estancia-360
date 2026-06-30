-- ============================================================
-- TABLA: ranch_pastures
-- MÓDULO: Gestión de Estancias — Potreros (Paddocks)
-- ============================================================
--
-- DESCRIPCIÓN:
--   Representa la división física del campo de una estancia. Los
--   potreros son los espacios físicos (hectáreas) donde se agrupan
--   los lotes de animales. Dentro de un potrero puede haber uno o
--   más lotes (ranch_lots).
--
-- RELACIÓN CON LOTES:
--   Un potrero (ranch_pasture) contiene uno o más lotes (ranch_lots).
--   Un lote siempre pertenece a un potrero.
--   Un animal siempre pertenece a un lote (y por ende a un potrero).
--
-- CAMPOS:
--   - area_hectares: superficie del potrero en hectáreas
--   - description:   descripción libre (ej: "campo natural", "campo sembrado")
--   - is_active:     FALSE si el potrero fue desactivado (deja de recibir animales)
--
-- LÓGICA BACKEND:
--   Al crear un potrero: verificar que id_ranch pertenezca al usuario.
--   Al desactivar (is_active=FALSE): verificar que no tenga lotes activos.
-- ============================================================

CREATE TABLE ranch_pastures (
    id_ranch_pasture bigserial,
    id_ranch int,
    name VARCHAR(50) NOT NULL,
    area_hectares DECIMAL(12, 2) NOT NULL,
    description TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    updated_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP NOT NULL,
    primary key (id_ranch_pasture),
    foreign key (id_ranch) references ranches(id_ranch)
);
ALTER TABLE ranch_pastures ADD COLUMN local_id VARCHAR(100) UNIQUE;
