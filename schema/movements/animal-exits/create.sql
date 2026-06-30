-- ============================================================
-- TABLA: animal_exits
-- MÓDULO: Movimientos — Muertes y Descartes
-- ============================================================
--
-- DESCRIPCIÓN:
--   Registra la salida definitiva de un animal por muerte, descarte,
--   pérdida u otra causa no comercial. Al registrar una salida, el
--   animal pasa a estado Baja (Discharged) e Inactivo.
--
-- CAUSAS (reason):
--   - death:    muerte natural o accidental
--   - discard:  descarte productivo (animal sin rendimiento, baja calidad genética)
--   - loss:     pérdida (animal no localizado, robo)
--   - other:    otra causa; debe documentarse en el campo notes
--
-- REGLAS DE NEGOCIO:
--   - RF-08.5: Se debe registrar la causa de la salida.
--   - RN-10: Un animal dado de baja NO puede reactivarse.
--
-- LÓGICA BACKEND (al registrar una salida):
--   1. Crear animal_event (id_event_type=10 'exit')
--   2. Crear animal_exits
--   3. Actualizar ranch_animals:
--      - id_productive_status = 4 (Discharged / Baja)
--      - id_status = 3 (Inactivo)
--
-- CAMPOS:
--   - reason: causa de la salida (categorizado con CHECK)
--   - notes:  detalle adicional obligatorio si reason='other'
-- ============================================================

CREATE TABLE animal_exits (
    id_exit             BIGSERIAL,
    id_event            BIGINT          NOT NULL,
    reason              VARCHAR(30)     NOT NULL
        CHECK (reason IN (
            'death',       -- muerte natural o accidental
            'discard',     -- descarte productivo (animal sin rendimiento)
            'loss',        -- pérdida (animal no localizado)
            'other'        -- otra causa documentada en notes
        )),
    notes               TEXT,
    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_exit),
    FOREIGN KEY (id_event) REFERENCES animal_events(id_animal_event)
);
