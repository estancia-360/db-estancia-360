-- ============================================================
-- MIGRACIÓN: 2026-06-13 — Tabla sync_deletions (tombstones)
-- ============================================================
--
-- MOTIVO:
--   Soporte para el nuevo endpoint GET /sync/download/:idRanch
--   (descarga incremental para app móvil offline-first).
--   Toda eliminación (hard delete) en los módulos de cría, recría
--   y engorde queda registrada aquí para que los clientes puedan
--   borrar esos registros de su base local en su próxima sync.
--
-- PARA REVERTIR: ejecutar down.sql de esta misma carpeta
-- ============================================================

CREATE TABLE sync_deletions (
    id_deletion     BIGSERIAL,
    id_ranch        BIGINT          NOT NULL,
    table_name      VARCHAR(50)     NOT NULL,
    record_id       BIGINT          NOT NULL,
    deleted_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_deletion),
    FOREIGN KEY (id_ranch) REFERENCES ranches(id_ranch)
);

CREATE INDEX idx_sync_deletions_ranch_date ON sync_deletions(id_ranch, deleted_at);
