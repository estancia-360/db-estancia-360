-- ============================================================
-- TABLA: movements
-- MÓDULO: Movimientos — Operación Batch de Movimiento
-- ============================================================
--
-- DESCRIPCIÓN:
--   Representa una operación de movimiento de animales. Una operación
--   puede involucrar uno o más animales de uno o varios lotes.
--   El detalle por animal se almacena en movement_animals.
--
--   La tabla es la "operación madre": guarda el tipo, el estado global
--   y los datos comerciales. movement_animals guarda el estado individual
--   de cada animal y el snapshot necesario para rollback.
--
-- TIPOS DE MOVIMIENTO (movement_type):
--   - sale:             Venta a comprador externo. Proceso en dos fases:
--                         Fase 1 — registrar: animals → id_status=4 (Pendiente)
--                         Fase 2 — confirmar por animal:
--                           accepted → id_status=5 (Vendido), ps=4 (Baja)
--                           rejected → id_status revierte a prev_id_status
--                       Solo OWNER (ranch_role=1) puede registrar.
--   - purchase:         Compra de animales externos. Se crean nuevos registros
--                       en ranch_animals con origin='purchased'. Solo OWNER.
--   - pasture_transfer: Traslado entre potreros o lotes dentro de la misma
--                       estancia. No cambia el id_status del animal, solo
--                       actualiza ranch_animals.id_lot = id_lot_dest.
--   - ranch_exit:       Salida hacia otra estancia del mismo propietario.
--                       La estancia destino registra su ingreso de forma
--                       independiente como una compra (sin FK entre estancias).
--                       Solo OWNER puede registrar.
--
-- ESTADOS GLOBALES (status):
--   - pending:    Movimiento registrado. Para sale/ranch_exit: animales en
--                 id_status=4 (Pendiente de Movimiento). Para pasture_transfer
--                 y purchase el status va directo a confirmed al crear.
--   - confirmed:  Operación finalizada. Animales en estado definitivo.
--   - cancelled:  Operación cancelada antes de confirmar. Todos los animales
--                 revirtieron a su estado previo (prev_id_status en movement_animals).
--
-- LÓGICA BACKEND — sale (POST /movements, PATCH /movements/:id/confirm, PATCH /movements/:id/cancel):
--   Registro (status=pending):
--     1. Verificar que quien registra es Owner (ranch_role=1)
--     2. Verificar que ningún animal tiene withdrawal_end_date >= HOY (RN-18)
--     3. Crear movements (status='pending')
--     4. Crear movement_animals por cada animal (status='pending',
--        prev_id_status = animal.id_status actual, id_lot_origin = animal.id_lot)
--     5. ranch_animals.id_status = 4 (Pendiente de Movimiento) para cada animal
--   Confirmación parcial (status=confirmed):
--     1. Para cada animal en movement_animals según decisión del operador:
--        - accepted → ranch_animals.id_status=5, id_productive_status=4
--        - rejected → ranch_animals.id_status = prev_id_status (revertir)
--     2. movements.status = 'confirmed'
--   Cancelación (status=cancelled):
--     1. Para cada animal: ranch_animals.id_status = prev_id_status
--     2. movements.status = 'cancelled'
--
-- LÓGICA BACKEND — purchase:
--   1. Verificar Owner
--   2. Crear movements (status='pending')
--   3. Crear ranch_animals nuevos (origin='purchased') con los datos del formulario
--   4. Crear movement_animals (status='confirmed', prev_id_status=1)
--   5. movements.status = 'confirmed'
--
-- LÓGICA BACKEND — pasture_transfer:
--   1. Crear movements (status='pending')
--   2. Crear movement_animals (id_lot_origin, id_lot_dest, prev_id_status, status='confirmed')
--   3. ranch_animals.id_lot = id_lot_dest para cada animal
--   4. movements.status = 'confirmed'
--
-- LÓGICA BACKEND — ranch_exit:
--   1. Verificar Owner
--   2. Crear movements (status='pending', counterpart_name=nombre estancia destino)
--   3. Crear movement_animals (prev_id_status, status='pending')
--   4. ranch_animals.id_status=5, id_productive_status=4 para cada animal
--   5. movements.status = 'confirmed'
--   Nota: la estancia destino registra su ingreso como type='purchase' de forma
--   independiente. No existe FK entre estancias en el sistema.
--
-- CAMPOS:
--   - id_ranch:          estancia donde ocurre el movimiento
--   - id_user:           usuario que registra (OWNER obligatorio en sale/purchase/ranch_exit)
--   - movement_type:     tipo de operación
--   - movement_date:     fecha efectiva de la operación
--   - status:            estado global del movimiento
--   - counterpart_name:  sale → nombre del comprador
--                        ranch_exit → nombre de la estancia destino (texto libre, sin FK)
--   - origin_name:       purchase → nombre del proveedor o estancia de origen (texto libre)
--   - total_price:       precio total acordado (sale/purchase)
--   - price_per_kg:      precio por kilogramo (indicador comercial, sale/purchase)
--   - notes:             observaciones adicionales sobre la operación
--   - local_id:          UUID generado por el cliente para idempotencia offline
--   - is_synced:         false si fue creado offline y aún no fue sincronizado al servidor
-- ============================================================

CREATE TABLE movements (
    id_movement         BIGSERIAL,
    id_ranch            BIGINT          NOT NULL,
    id_user             BIGINT,
    movement_type       VARCHAR(30)     NOT NULL
        CHECK (movement_type IN (
            'sale',              -- venta a comprador externo (dos fases)
            'purchase',          -- compra de animales externos
            'pasture_transfer',  -- traslado entre potreros/lotes (misma estancia)
            'ranch_exit'         -- salida hacia otra estancia del mismo propietario
        )),
    movement_date       DATE            NOT NULL,
    status              VARCHAR(30)     NOT NULL DEFAULT 'pending'
        CHECK (status IN (
            'pending',    -- registrado, en espera de confirmación
            'confirmed',  -- finalizado, animales en estado definitivo
            'cancelled'   -- cancelado, animales revertidos al estado previo
        )),
    counterpart_name    VARCHAR(200),
    origin_name         VARCHAR(200),
    total_price         NUMERIC(12, 2),
    price_per_kg        NUMERIC(8,  2),
    notes               TEXT,
    local_id            VARCHAR(100) UNIQUE,
    is_synced           BOOLEAN         NOT NULL DEFAULT FALSE,
    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_movement),
    FOREIGN KEY (id_ranch) REFERENCES ranches(id_ranch),
    FOREIGN KEY (id_user)  REFERENCES users(id_user)
);
