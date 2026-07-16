-- ============================================================
-- ROLLBACK: 2026-07-15 — subscription_payments: agregar local_id
-- ============================================================

ALTER TABLE subscription_payments
    DROP COLUMN IF EXISTS local_id;
