-- ============================================================
-- TABLA: sync_deletions
-- MÓDULO: Core — Sincronización Offline (tombstones)
-- ============================================================
--
-- DESCRIPCIÓN:
--   Registro genérico de eliminaciones (hard delete) para soportar
--   sincronización incremental con clientes offline (app móvil / web).
--   Cuando un registro de cualquier tabla sincronizable es eliminado,
--   se inserta una fila aquí con la tabla y el ID afectado.
--
-- USO (GET /sync/download/:idRanch?since=):
--   El servidor devuelve en `deletions` todas las filas con
--   deleted_at > since, agrupadas por table_name, para que el
--   cliente borre esos registros de su base local.
--
-- ESCRITURA:
--   SyncDeletionsService.log()/.logBatch() — llamado dentro de la misma
--   transacción que el DELETE real, en todos los use-cases de borrado
--   de cría, recría y engorde.
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
