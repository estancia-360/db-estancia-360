-- ============================================================
-- TABLA: animal_transfers
-- MÓDULO: Movimientos — Traslados Internos de Animales
-- ============================================================
--
-- DESCRIPCIÓN:
--   Registra el traslado de un animal de un lote a otro dentro de la
--   misma estancia. El cambio de potrero se infiere del cambio de lote
--   (cada lote pertenece a un potrero, si los potreros son distintos
--   es un traslado de potrero; si son el mismo es traslado de lote).
--
-- MOTIVOS DE TRASLADO (reason):
--   - management: reajuste de carga o manejo operativo
--   - breeding:   traslado para incorporar al ciclo reproductivo
--   - rearing:    traslado entre lotes de recría
--   - fattening:  traslado entre lotes de engorde
--   - health:     cuarentena o separación por evento sanitario
--
-- LÓGICA BACKEND (al registrar un traslado):
--   1. Crear animal_event (id_event_type=9 'transfer')
--   2. Crear animal_transfers con lote origen y destino
--   3. Actualizar ranch_animals.id_lot = id_lot_dest del animal
--
-- CAMPOS:
--   - id_lot_origin: lote de donde sale el animal (lote actual antes del traslado)
--   - id_lot_dest:   lote al que ingresa el animal
--   - reason:        motivo del traslado (categorizado)
-- ============================================================

CREATE TABLE animal_transfers (
    id_transfer         BIGSERIAL,
    id_event            BIGINT          NOT NULL,
    id_lot_origin       BIGINT          NOT NULL,
    id_lot_dest         BIGINT          NOT NULL,
    reason              VARCHAR(30)
        CHECK (reason IN (
            'management',
            'breeding',
            'rearing',
            'fattening',
            'health'
        )),
    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_transfer),
    FOREIGN KEY (id_event)      REFERENCES animal_events(id_animal_event),
    FOREIGN KEY (id_lot_origin) REFERENCES ranch_lots(id_lot),
    FOREIGN KEY (id_lot_dest)   REFERENCES ranch_lots(id_lot)
);
