-- ============================================================
-- TABLA: subscription_plans  [CATÁLOGO — gestionado por Estancia360]
-- MÓDULO: Pagos / Suscripciones
-- ============================================================
--
-- DESCRIPCIÓN:
--   Catálogo de planes comerciales de Estancia360. Cada estancia tiene
--   asignado un plan (ranch_subscriptions.id_plan). El límite entre
--   planes es la capacidad de animales — en el MVP todas las funciones
--   están disponibles en todos los planes por igual.
--
-- NO ES UNA PASARELA DE PAGOS: el cobro sigue siendo manual
--   (QR/transferencia, comprobante por correo). Este catálogo y el
--   resto del módulo son solo la capa administrativa que registra el
--   estado de la suscripción y controla acceso según eso.
--
-- CAMPOS:
--   - capacity_min/capacity_max: rango de cantidad de animales que
--     cubre el plan. capacity_max=NULL → sin límite (Ganadero Plus).
--   - price_monthly/price_annual: precios de referencia (Bs). El anual
--     ya viene descontado (10 meses de precio, 12 de acceso) — eso se
--     resuelve solo al otorgar 12 meses de current_period_end por un
--     pago con billing_cycle='annual', no requiere lógica aparte.
--   - trial_days: días de prueba gratuita al activar el plan por
--     primera vez. 0 para Free (no es un trial, es un plan permanente).
--   - is_active: permite retirar un plan de venta sin borrar el
--     historial de estancias que ya lo tengan asignado.
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
