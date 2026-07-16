-- ============================================================
-- MIGRACIÓN: 2026-07-15 — subscription_payments: agregar local_id
-- ============================================================
--
-- MOTIVO:
--   POST /admin/subscriptions/:idRanch/payments no tenía protección contra
--   doble envío. Un doble clic del admin en el panel (cuando exista) crea
--   dos pagos y extiende current_period_end el doble, sin que nadie se dé
--   cuenta — a diferencia del resto de los endpoints de creación del
--   proyecto, que ya usan local_id para esto. Pagos no tiene sync offline,
--   pero el mismo mecanismo sirve como idempotencia ante reintentos/doble
--   clic del cliente HTTP.
--
-- PARA REVERTIR: ejecutar down.sql de esta misma carpeta
-- ============================================================

ALTER TABLE subscription_payments
    ADD COLUMN IF NOT EXISTS local_id VARCHAR(100) UNIQUE;
