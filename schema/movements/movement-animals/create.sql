-- ============================================================
-- TABLA: movement_animals
-- MÓDULO: Movimientos — Detalle por Animal en una Operación
-- ============================================================
--
-- DESCRIPCIÓN:
--   Registra la participación de cada animal individual dentro de
--   una operación de movimiento (movements). Permite confirmar o
--   rechazar animales de forma independiente dentro de una venta,
--   y revertir el estado del animal al cancelar una operación.
--
-- RELACIÓN: N movement_animals → 1 movements
--
-- ESTADOS POR ANIMAL (status):
--   - pending:   Animal incluido en el movimiento, operación aún no confirmada.
--                ranch_animals.id_status fue actualizado a 4 (Pendiente de Movimiento).
--   - accepted:  Animal aceptado. Para ventas y ranch_exit:
--                ranch_animals.id_status=5 (Vendido), id_productive_status=4 (Baja).
--   - rejected:  Animal rechazado en una venta. ranch_animals.id_status revierte
--                a prev_id_status. El animal permanece disponible en la estancia.
--   - confirmed: Operación finalizada (pasture_transfer, purchase, ranch_exit).
--                ranch_animals actualizado al estado final correspondiente.
--
-- ROLLBACK (cancelación o rechazo):
--   prev_id_status guarda el ranch_animals.id_status ANTES del movimiento.
--   El servidor lo usa para revertir ranch_animals.id_status al cancelar o rechazar.
--   Siempre lo setea el servidor al procesar el sync — el cliente nunca lo envía.
--
-- SINCRONIZACIÓN:
--   Soporta create y update offline. El cliente asigna un local_id único por
--   registro. Al sincronizar:
--     - Si el local_id no existe en servidor → INSERT
--     - Si el local_id ya existe → UPDATE (actualiza status, notes)
--   is_synced=false indica que fue creado o modificado offline y aún no confirmado
--   por el servidor.
--
-- CAMPOS:
--   - id_movement:      FK a la operación madre (movements)
--   - id_ranch_animal:  animal involucrado en el movimiento
--   - id_lot_origin:    snapshot del lote del animal ANTES del movimiento
--                       pasture_transfer: lote de salida
--                       sale/ranch_exit: lote actual al momento de registrar
--                       purchase: NULL (el animal es nuevo, no tenía lote previo)
--   - id_lot_dest:      lote destino del animal
--                       pasture_transfer: lote al que se traslada
--                       sale/ranch_exit/purchase: NULL (no aplica)
--   - prev_id_status:   snapshot de ranch_animals.id_status antes de la operación
--                       usado exclusivamente para rollback en cancel o reject
--                       lo setea el servidor, nunca el cliente
--   - status:           estado del animal dentro de la operación
--   - id_event:         FK a animal_events, se llena al confirmar (server-side)
--                       NULL mientras el movimiento está en status=pending
--                       NULL si el animal es rechazado (no genera evento)
--   - notes:            observación por animal (ej. motivo de rechazo del comprador)
--   - local_id:         UUID generado por el cliente para idempotencia en sync
--   - is_synced:        false si fue creado o modificado offline
-- ============================================================

CREATE TABLE movement_animals (
    id_movement_animal  BIGSERIAL,
    id_movement         BIGINT          NOT NULL,
    id_ranch_animal     BIGINT          NOT NULL,
    id_lot_origin       BIGINT,
    id_lot_dest         BIGINT,
    prev_id_status      INT             NOT NULL,
    status              VARCHAR(30)     NOT NULL DEFAULT 'pending'
        CHECK (status IN (
            'pending',    -- en espera de confirmación
            'accepted',   -- aceptado → id_status=5 (Vendido), ps=4 (Baja)
            'rejected',   -- rechazado → id_status revierte a prev_id_status
            'confirmed'   -- finalizado (pasture_transfer / purchase / ranch_exit)
        )),
    id_event            BIGINT,
    notes               TEXT,
    local_id            VARCHAR(100) UNIQUE,
    is_synced           BOOLEAN         NOT NULL DEFAULT FALSE,
    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_movement_animal),
    FOREIGN KEY (id_movement)     REFERENCES movements(id_movement) ON DELETE CASCADE,
    FOREIGN KEY (id_ranch_animal) REFERENCES ranch_animals(id_ranch_animal),
    FOREIGN KEY (id_lot_origin)   REFERENCES ranch_lots(id_lot),
    FOREIGN KEY (id_lot_dest)     REFERENCES ranch_lots(id_lot),
    FOREIGN KEY (id_event)        REFERENCES animal_events(id_animal_event)
);
