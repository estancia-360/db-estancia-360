-- ============================================================
-- MIGRACIÓN: 2026-05-23 — Módulo Movimientos (Rediseño Completo)
-- ============================================================
--
-- MOTIVO:
--   El módulo de movimientos fue rediseñado según el documento
--   "MÓDULO MOVIMIENTOS_COMPLETO" (entregado 2026-05-23).
--   Los cambios principales son:
--
--   1. VENTAS — proceso en DOS FASES (cambio crítico):
--      Antes: venta inmediata e irreversible → ps=4, status=3 al instante.
--      Ahora:
--        Fase 1 (registrar): animales pasan a id_status=4 "Pendiente de Movimiento".
--        Fase 2 (confirmar por animal):
--          - Aceptado → id_status=5 "Vendido", id_productive_status=4 (Baja)
--          - Rechazado → id_status revierte al valor anterior (animal disponible)
--        Cancelación: todos los animales revierten al estado previo.
--
--   2. REDISEÑO DE TABLAS:
--      Las tablas animal_transfers, animal_sales y animal_purchases usaban
--      un modelo event-first (un registro por animal). Este modelo no soporta:
--        - Operaciones batch sobre múltiples lotes (RF-05)
--        - El proceso de dos fases de ventas (RF-07, RF-08, RF-09)
--        - Cancelación con rollback de estado (RF-14, RF-15, RN-13)
--        - Sincronización de create y update por registro individual
--      Son reemplazadas por:
--        - movements:        operación madre (tipo, estado global, datos comerciales)
--        - movement_animals: detalle por animal (estado individual, snapshot rollback)
--
--   3. NUEVOS ESTADOS en animal_statuses:
--      id=4: "Pendiente de Movimiento" — temporal durante venta activa (pending)
--      id=5: "Vendido"                 — estado final tras confirmación de venta
--
--   4. TABLAS PRESERVADAS SIN CAMBIOS:
--      - animal_exits: bajas por muerte/descarte (concepto distinto a venta/movimiento)
--
-- TABLAS ELIMINADAS:  animal_transfers, animal_sales, animal_purchases
-- TABLAS CREADAS:     movements, movement_animals
-- DATOS MODIFICADOS:  animal_statuses (2 filas nuevas, sin cambio de schema)
--
-- PARA REVERTIR: ejecutar down.sql de esta misma carpeta
-- ============================================================

-- ============================================================
-- PASO 1: Verificar que las tablas a eliminar estén vacías
-- ============================================================
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'public' AND table_name = 'animal_transfers'
    ) AND (SELECT COUNT(*) FROM animal_transfers) > 0 THEN
        RAISE EXCEPTION
            'MIGRACIÓN ABORTADA: animal_transfers contiene % filas. '
            'Exportar o migrar datos manualmente antes de continuar.',
            (SELECT COUNT(*) FROM animal_transfers);
    END IF;

    IF EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'public' AND table_name = 'animal_sales'
    ) AND (SELECT COUNT(*) FROM animal_sales) > 0 THEN
        RAISE EXCEPTION
            'MIGRACIÓN ABORTADA: animal_sales contiene % filas. '
            'Exportar o migrar datos manualmente antes de continuar.',
            (SELECT COUNT(*) FROM animal_sales);
    END IF;

    IF EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'public' AND table_name = 'animal_purchases'
    ) AND (SELECT COUNT(*) FROM animal_purchases) > 0 THEN
        RAISE EXCEPTION
            'MIGRACIÓN ABORTADA: animal_purchases contiene % filas. '
            'Exportar o migrar datos manualmente antes de continuar.',
            (SELECT COUNT(*) FROM animal_purchases);
    END IF;
END $$;

-- ============================================================
-- PASO 2: Eliminar tablas antiguas del módulo movimientos
-- ============================================================
DROP TABLE IF EXISTS animal_transfers CASCADE;
DROP TABLE IF EXISTS animal_sales     CASCADE;
DROP TABLE IF EXISTS animal_purchases CASCADE;

-- ============================================================
-- PASO 3: Nuevos estados en el catálogo animal_statuses
-- ============================================================
INSERT INTO animal_statuses (id_status, name) VALUES
    (4, 'Pendiente de Movimiento'),
    (5, 'Vendido')
ON CONFLICT (id_status) DO NOTHING;

-- ============================================================
-- PASO 4: Nueva tabla movements (operación madre batch)
-- ============================================================
CREATE TABLE IF NOT EXISTS movements (
    id_movement         BIGSERIAL,
    id_ranch            BIGINT          NOT NULL,
    id_user             BIGINT,
    movement_type       VARCHAR(30)     NOT NULL
        CHECK (movement_type IN (
            'sale',
            'purchase',
            'pasture_transfer',
            'ranch_exit'
        )),
    movement_date       DATE            NOT NULL,
    status              VARCHAR(30)     NOT NULL DEFAULT 'pending'
        CHECK (status IN (
            'pending',
            'confirmed',
            'cancelled'
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

-- ============================================================
-- PASO 5: Nueva tabla movement_animals (detalle por animal)
-- ============================================================
CREATE TABLE IF NOT EXISTS movement_animals (
    id_movement_animal  BIGSERIAL,
    id_movement         BIGINT          NOT NULL,
    id_ranch_animal     BIGINT          NOT NULL,
    id_lot_origin       BIGINT,
    id_lot_dest         BIGINT,
    prev_id_status      INT             NOT NULL,
    status              VARCHAR(30)     NOT NULL DEFAULT 'pending'
        CHECK (status IN (
            'pending',
            'accepted',
            'rejected',
            'confirmed'
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

-- ============================================================
-- VERIFICACIÓN (ejecutar después del COMMIT para confirmar)
-- ============================================================
-- SELECT id_status, name FROM animal_statuses ORDER BY id_status;
-- SELECT to_regclass('public.movements');
-- SELECT to_regclass('public.movement_animals');
-- SELECT to_regclass('public.animal_transfers');  -- debe devolver NULL
-- SELECT to_regclass('public.animal_sales');      -- debe devolver NULL
-- SELECT to_regclass('public.animal_purchases');  -- debe devolver NULL
