-- ============================================================
-- TABLA: ranch_lots
-- MÓDULO: Gestión de Estancias — Lotes de Animales
-- ============================================================
--
-- DESCRIPCIÓN:
--   Representa un grupo de animales dentro de un potrero. Los lotes son
--   la unidad de manejo operativo del sistema: los pesajes, traslados y
--   alimentación se gestionan a nivel de lote. Todo animal pertenece
--   a un lote (ranch_animals.id_lot).
--
-- TIPOS DE LOTE (lot_type):
--   - breeding:     lote para vacas en ciclo reproductivo (módulo Cría)
--   - rearing:      lote para animales en crecimiento post-destete (Recría)
--   - fattening:    lote para animales en terminación antes de venta (Engorde)
--   - reproductive: lote para toros y reproductores
--   - general:      lote mixto o sin clasificación específica
--
--   El tipo de lote determina qué módulo puede operar sobre él.
--   RF-01.5: Los módulos solo operan si la estancia tiene habilitado el
--   rubro correspondiente (ranch_production_types).
--
-- RELACIÓN CON MÓDULOS:
--   - Lotes 'rearing':    destino en weanings.id_lot_dest y rearing_selections.id_lot_dest
--   - Lotes 'fattening':  destino en fattening_entries (referenciado vía animal_events)
--   - Todos los lotes:    destino en animal_transfers.id_lot_dest
--   - Todos los lotes:    referenciado en feed_records.id_lot (alimentación)
--   - Todos los lotes:    referenciado en weight_records.id_lot (pesajes)
--
-- CAMPOS:
--   - capacity: número máximo de animales que el lote puede contener (RF-01.6).
--               NULL = sin límite definido. El backend puede alertar si se supera.
--   - is_active: FALSE si el lote fue cerrado (ya no acepta nuevos animales)
--
-- LÓGICA BACKEND:
--   Al asignar un animal a un lote: verificar que el lote es del tipo correcto
--   para la etapa productiva del animal y que la estancia tiene ese rubro activo.
-- ============================================================

CREATE TABLE ranch_lots (
    id_lot              BIGSERIAL,
    id_ranch            INT,
    id_ranch_pasture    BIGINT          NOT NULL,
    name                VARCHAR(50)     NOT NULL,
    lot_type            VARCHAR(30)
        CHECK (lot_type IN (
            'cria',
            'recria',
            'engorde',
            'reproductiva',
            'general'
        )),
    capacity            INT,                           -- capacidad máxima de animales del lote (RF-01.6)
    is_active           BOOLEAN         NOT NULL DEFAULT TRUE,
    updated_at          TIMESTAMP       NOT NULL,
    created_at          TIMESTAMP       NOT NULL,
    PRIMARY KEY (id_lot),
    FOREIGN KEY (id_ranch) REFERENCES ranches(id_ranch),
    FOREIGN KEY (id_ranch_pasture) REFERENCES ranch_pastures(id_ranch_pasture)
);
ALTER TABLE ranch_lots ADD COLUMN local_id VARCHAR(100) UNIQUE;
