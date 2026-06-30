# sync_deletions

Registro genérico de eliminaciones (tombstones) para soportar la sincronización incremental de la app móvil/web offline-first. Cuando un registro de cualquier tabla sincronizable se elimina, se inserta aquí una fila con la tabla y el ID afectados.

## Columnas

| Columna | Tipo | Nulo | Default | Descripción |
|---------|------|------|---------|-------------|
| id_deletion | BIGSERIAL | NO | autoincremental | Identificador único del registro de eliminación. |
| id_ranch | BIGINT | NO | — | Estancia propietaria del registro eliminado. |
| table_name | VARCHAR(50) | NO | — | Nombre de la tabla de origen del registro eliminado. |
| record_id | BIGINT | NO | — | Identificador del registro eliminado dentro de su tabla de origen. |
| deleted_at | TIMESTAMP | NO | CURRENT_TIMESTAMP | Fecha y hora en que se eliminó el registro. |

## Relaciones

| Columna | Referencia | Descripción |
|---------|------------|-------------|
| id_ranch | ranches.id_ranch | Estancia a la que pertenecía el registro eliminado; delimita qué clientes deben recibir esta eliminación al sincronizar. |

## Reglas de negocio

- Cada eliminación (hard delete) de un registro sincronizable debe loguearse aquí en la misma transacción que el DELETE real.
- El endpoint `GET /sync/download/:idRanch?since=` devuelve todas las filas con `deleted_at > since`, agrupadas por `table_name`, para que el cliente offline borre esos registros de su base local.
- `record_id` no tiene FK hacia la tabla original porque el registro referenciado ya no existe tras el borrado.

## Notas técnicas

- Índice `idx_sync_deletions_ranch_date` sobre `(id_ranch, deleted_at)` para optimizar la consulta incremental por estancia y fecha.
- La escritura la realiza `SyncDeletionsService.log()`/`.logBatch()`, invocado dentro de la misma transacción que el DELETE real en los use-cases de borrado de Cría, Recría y Engorde.
