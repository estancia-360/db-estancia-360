-- ============================================================
-- TABLA: subscription_payments
-- MÓDULO: Pagos / Suscripciones
-- ============================================================
--
-- DESCRIPCIÓN:
--   Historial de pagos registrados para una suscripción. Cada fila es
--   un pago confirmado que extiende ranch_subscriptions.current_period_end.
--   NO es una pasarela: hoy siempre lo carga un admin a mano después de
--   recibir el comprobante (QR/transferencia) por correo.
--
-- CAMPOS:
--   - payment_method: cómo pagó el cliente (QR o transferencia).
--   - payment_source: quién generó el registro. Hoy siempre 'manual'.
--     Existe desde ahora para que, cuando exista una pasarela de pagos
--     real, un webhook pueda insertar filas con payment_source='gateway'
--     sin tener que cambiar el modelo de datos.
--   - external_reference: referencia libre del comprobante (nombre de
--     archivo, número de operación) hoy; ID de transacción de la
--     pasarela en el futuro.
--   - period_extended_months: cuántos meses se suman a current_period_end
--     por este pago. No se deriva rígido de billing_cycle (1 o 12) para
--     poder cargar promociones manuales (ej. "paga 3 meses, recibe 4")
--     sin necesitar un caso especial en el código.
--   - registered_by: usuario (admin) que cargó el pago. Con pasarela
--     futura, quedaría NULL o apuntando a un usuario de sistema.
--   - local_id: idempotencia ante doble envío del cliente HTTP (doble clic
--     en el panel admin). El módulo no tiene sync offline, pero reutiliza
--     el mismo mecanismo que el resto del proyecto.
-- ============================================================

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
    local_id                 VARCHAR(100)    UNIQUE,
    created_at               TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_payment),
    FOREIGN KEY (id_ranch_subscription) REFERENCES ranch_subscriptions(id_ranch_subscription),
    FOREIGN KEY (registered_by) REFERENCES users(id_user)
);
