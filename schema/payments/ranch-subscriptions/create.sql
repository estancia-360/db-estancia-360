-- ============================================================
-- TABLA: ranch_subscriptions
-- MÓDULO: Pagos / Suscripciones
-- ============================================================
--
-- DESCRIPCIÓN:
--   Suscripción vigente de una estancia (1:1 — cada estancia tiene una
--   sola fila, nunca historial de suscripciones viejas acá; el
--   historial de pagos vive en subscription_payments). Se crea
--   automáticamente en plan Free al registrar la estancia.
--
-- ESTADO — CALCULADO POR FECHA, NO ALMACENADO:
--   Esta tabla NO tiene columna "status". El estado efectivo se
--   calcula en el backend a partir de estas 3 columnas:
--     - Si cancelled_at NOT NULL           → cancelled
--     - Si hoy < trial_ends_at             → trial
--     - Si hoy <= current_period_end        → active
--     - Si no                              → expired
--   Esto evita depender de un cron/job que actualice un campo
--   "status" — el cálculo siempre está al día porque se hace en el
--   momento de la consulta, nunca se guarda una verdad que pueda
--   desincronizarse.
--
-- CAMPOS:
--   - billing_cycle:      'monthly' | 'annual' | NULL (NULL en Free,
--                         que no tiene ciclo de facturación)
--   - trial_ends_at:      fin del período de prueba gratuita al activar
--                         un plan pago por primera vez. NULL en Free.
--   - current_period_end: fecha hasta la que está pago el plan actual.
--                         Se extiende cada vez que se registra un pago
--                         (subscription_payments). NULL en Free.
--   - cancelled_at:       fecha en que un admin canceló la suscripción
--                         a mano. Es la única transición que es una
--                         decisión explícita, no derivada de fechas.
--
-- LÓGICA DE ACCESO (aplicada en el backend, no en la DB):
--   - Capacidad de animales: si el estado efectivo es 'expired', la
--     estancia vuelve al límite de capacidad del plan Free (30) para
--     registrar animales NUEVOS. Los animales existentes no se tocan.
--   - Acceso web (a futuro): guard más estricto que puede bloquear el
--     acceso completo si el estado es 'expired'/'cancelled'.
-- ============================================================

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
