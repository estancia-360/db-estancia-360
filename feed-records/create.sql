-- ============================================================
-- TABLA: feed_records
-- MÓDULO: Engorde — Registro de Alimentación por Lote
-- ============================================================
--
-- DESCRIPCIÓN:
--   Registra el suministro de alimento a un LOTE de animales. Es la
--   ÚNICA tabla transaccional del sistema que no pasa por animal_events,
--   porque la alimentación se gestiona a nivel de lote, no por animal
--   individual (una sola medición para todo el lote).
--
-- POR ESO TIENE SU PROPIO is_synced:
--   Al no estar vinculada a animal_events, necesita su propio campo
--   is_synced para el seguimiento offline (RNF-01.4).
--
-- CÓMO SE USA (RF-06.2):
--   El responsable registra qué se le dio al lote, cuánto y a qué costo.
--   El tipo de alimento es texto libre (maíz, balanceado, heno, etc.).
--   La cantidad y unidad permiten calcular el consumo total del período.
--
-- CONVERSIÓN ALIMENTICIA (RF-06.4 — calculada, no almacenada):
--   Para un lote en un período:
--   consumo_total  = SUM(quantity) de feed_records del lote en el período
--   ganancia_total = SUM(delta de weight entre registros de weight_records)
--   eficiencia     = consumo_total / ganancia_total
--   → Este cálculo lo hace el backend al consultar indicadores de Engorde.
--
-- REGLAS:
--   - El lote debe ser de tipo 'fattening' para registrar alimentación de Engorde.
--     (También puede usarse para lotes 'rearing' si corresponde.)
--   - id_user es quien registra (no genera animal_event, no hay id_event_type).
--
-- CAMPOS:
--   - id_lot:     lote al que se suministró el alimento
--   - id_user:    usuario que registró el suministro
--   - feed_date:  fecha del suministro
--   - feed_type:  tipo de alimento (texto libre: maíz, balanceado, heno, etc.)
--   - quantity:   cantidad suministrada
--   - unit:       unidad (kg, bolsas, fardos; NULL = kg por defecto)
--   - cost:       costo total del suministro (indicador económico)
--   - is_synced:  FALSE = pendiente de sincronizar (propio de esta tabla)
-- ============================================================

CREATE TABLE feed_records (
    id_feed             BIGSERIAL,
    id_lot              BIGINT          NOT NULL,
    id_user             BIGINT,
    feed_date           DATE            NOT NULL,
    feed_type           VARCHAR(150)    NOT NULL,                   -- texto libre: maíz, balanceado, etc.
    quantity            NUMERIC(10,2),                             -- cantidad suministrada
    unit                VARCHAR(20),                               -- kg, bolsas, etc. (null = kg por defecto)
    cost                NUMERIC(10,2),                             -- costo total del suministro
    notes               TEXT,
    is_synced           BOOLEAN         NOT NULL DEFAULT FALSE,    -- RNF-01.4: única tabla fuera de animal_events
    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_feed),
    FOREIGN KEY (id_lot)  REFERENCES ranch_lots(id_lot),
    FOREIGN KEY (id_user) REFERENCES users(id_user)
);
