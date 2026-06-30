# sync_deletions

Soporte para el nuevo endpoint `GET /sync/download/:idRanch` (descarga incremental para app móvil offline-first). Toda eliminación (hard delete) en los módulos de cría, recría y engorde queda registrada aquí para que los clientes puedan borrar esos registros de su base local en su próxima sync.
