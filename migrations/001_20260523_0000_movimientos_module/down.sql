-- ============================================================
-- ROLLBACK: 2026-05-23 — Módulo Movimientos (Rediseño Completo)
-- ============================================================
--
-- PROPÓSITO:
--   Revierte todos los cambios aplicados por up.sql de esta carpeta.
--   Restaura el estado de la base de datos al que tenía ANTES de la migración.
--
-- ADVERTENCIA:
--   Este rollback elimina las tablas movements y movement_animals con todos
--   sus datos. Solo ejecutar si se está seguro de que no hay información
--   valiosa en esas tablas o si se hizo un backup previo.
--
-- ORDEN DE EJECUCIÓN: exactamente inverso al up.sql
--   1. Eliminar movement_animals y movements (tablas nuevas)
--   2. Quitar los estados nuevos de animal_statuses
--   3. Recrear animal_transfers, animal_sales, animal_purchases (tablas antiguas)
-- ============================================================

-- ============================================================
-- PASO 1: Eliminar tablas nuevas
-- ============================================================
DROP TABLE IF EXISTS movement_animals CASCADE;
DROP TABLE IF EXISTS movements         CASCADE;

-- ============================================================
-- PASO 2: Quitar los estados nuevos del catálogo
-- ============================================================
DELETE FROM animal_statuses WHERE id_status IN (4, 5);

-- ============================================================
-- PASO 3: Restaurar tablas antiguas
-- ============================================================

CREATE TABLE IF NOT EXISTS animal_transfers (
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

CREATE TABLE IF NOT EXISTS animal_sales (
    id_sale             BIGSERIAL,
    id_event            BIGINT          NOT NULL,
    buyer               VARCHAR(150),
    destination         VARCHAR(150),
    sale_price          NUMERIC(12, 2),
    price_per_kg        NUMERIC(8,  2),
    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_sale),
    FOREIGN KEY (id_event) REFERENCES animal_events(id_animal_event)
);

CREATE TABLE IF NOT EXISTS animal_purchases (
    id_purchase         BIGSERIAL,
    id_event            BIGINT          NOT NULL,
    supplier            VARCHAR(150),
    origin              VARCHAR(150),
    purchase_price      NUMERIC(12, 2),
    price_per_kg        NUMERIC(8,  2),
    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_purchase),
    FOREIGN KEY (id_event) REFERENCES animal_events(id_animal_event)
);

-- ============================================================
-- VERIFICACIÓN (ejecutar después del COMMIT para confirmar)
-- ============================================================
-- SELECT id_status, name FROM animal_statuses ORDER BY id_status;
-- SELECT to_regclass('public.movements');          -- debe devolver NULL
-- SELECT to_regclass('public.movement_animals');   -- debe devolver NULL
-- SELECT to_regclass('public.animal_transfers');   -- debe existir
-- SELECT to_regclass('public.animal_sales');       -- debe existir
-- SELECT to_regclass('public.animal_purchases');   -- debe existir
