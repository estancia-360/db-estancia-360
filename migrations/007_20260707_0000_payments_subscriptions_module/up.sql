-- ============================================================
-- MIGRACIÓN: 2026-07-07 — módulo de Pagos/Suscripciones
-- ============================================================
--
-- MOTIVO:
--   Primera versión del módulo administrativo de suscripciones
--   (Free/Estancia/Hacienda/Ganadero Plus). No es una pasarela de
--   pagos — el cobro sigue siendo manual (QR/transferencia); este
--   módulo registra el estado y controla la capacidad de animales
--   por plan. Ver documentos/Flujo_Caja_Estancia360_RECONSTRUIDO_sin_VALUE.xlsx.
--
-- PARA REVERTIR: ejecutar down.sql de esta misma carpeta
-- ============================================================

CREATE TABLE subscription_plans (
    id_plan         SERIAL,
    name            VARCHAR(30)     NOT NULL,
    capacity_min    INT             NOT NULL,
    capacity_max    INT,
    price_monthly   NUMERIC(8,2)    NOT NULL,
    price_annual    NUMERIC(8,2)    NOT NULL,
    trial_days      INT             NOT NULL DEFAULT 0,
    is_active       BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_plan)
);

INSERT INTO subscription_plans (id_plan, name, capacity_min, capacity_max, price_monthly, price_annual, trial_days, is_active) VALUES
(1, 'Free',          0,    30,   0,   0,    0,  TRUE),
(2, 'Estancia',      31,   350,  100, 1000, 7,  TRUE),
(3, 'Hacienda',      351,  1500, 300, 3000, 14, TRUE),
(4, 'Ganadero Plus', 1501, NULL, 450, 4500, 21, TRUE);

CREATE TABLE ranch_subscriptions (
    id_ranch_subscription   BIGSERIAL,
    id_ranch                BIGINT          NOT NULL,
    id_plan                 INT             NOT NULL,
    billing_cycle           VARCHAR(10)
        CHECK (billing_cycle IN ('monthly', 'annual')),
    trial_ends_at           DATE,
    current_period_end      DATE,
    cancelled_at            DATE,
    created_at              TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_ranch_subscription),
    UNIQUE (id_ranch),
    FOREIGN KEY (id_ranch) REFERENCES ranches(id_ranch),
    FOREIGN KEY (id_plan) REFERENCES subscription_plans(id_plan)
);

CREATE TABLE subscription_payments (
    id_payment              BIGSERIAL,
    id_ranch_subscription   BIGINT          NOT NULL,
    amount                  NUMERIC(10,2)   NOT NULL,
    payment_date             DATE            NOT NULL,
    payment_method           VARCHAR(20)     NOT NULL
        CHECK (payment_method IN ('qr', 'transfer')),
    payment_source           VARCHAR(20)     NOT NULL DEFAULT 'manual'
        CHECK (payment_source IN ('manual', 'gateway')),
    external_reference       VARCHAR(255),
    period_extended_months   INT             NOT NULL,
    registered_by            BIGINT,
    notes                    TEXT,
    created_at               TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_payment),
    FOREIGN KEY (id_ranch_subscription) REFERENCES ranch_subscriptions(id_ranch_subscription),
    FOREIGN KEY (registered_by) REFERENCES users(id_user)
);

-- Backfill: toda estancia que ya exista queda en plan Free por defecto
INSERT INTO ranch_subscriptions (id_ranch, id_plan)
SELECT r.id_ranch, 1
FROM ranches r
WHERE NOT EXISTS (
    SELECT 1 FROM ranch_subscriptions rs WHERE rs.id_ranch = r.id_ranch
);
