# movement_animals

Registra la participación de cada animal individual dentro de una operación de movimiento (`movements`). Permite confirmar o rechazar animales de forma independiente dentro de una venta, y revertir el estado del animal al cancelar una operación.

## Columnas

| Columna | Tipo | Nulo | Default | Descripción |
|---------|------|------|---------|-------------|
| id_movement_animal | BIGSERIAL | NO | autoincremental | Identificador único del detalle por animal. |
| id_movement | BIGINT | NO | — | Operación de movimiento a la que pertenece este detalle. |
| id_ranch_animal | BIGINT | NO | — | Animal involucrado en el movimiento. |
| id_lot_origin | BIGINT | SÍ | — | Lote del animal antes del movimiento (snapshot). NULL en `purchase`, ya que el animal es nuevo. |
| id_lot_dest | BIGINT | SÍ | — | Lote destino del animal. Solo aplica en `pasture_transfer`; NULL en `sale`/`ranch_exit`/`purchase`. |
| prev_id_status | INT | NO | — | Snapshot del `id_status` del animal antes de la operación, usado exclusivamente para revertir en cancelación o rechazo. |
| status | VARCHAR(30) | NO | 'pending' | Estado del animal dentro de la operación: `pending`, `accepted`, `rejected` o `confirmed`. |
| id_event | BIGINT | SÍ | — | Evento de animal generado al confirmar la operación; NULL mientras está pendiente o si el animal fue rechazado. |
| notes | TEXT | SÍ | — | Observación particular del animal dentro de la operación (ej. motivo de rechazo). |
| local_id | VARCHAR(100) | SÍ | — | Identificador generado por el cliente offline para idempotencia al sincronizar. |
| is_synced | BOOLEAN | NO | FALSE | Indica si el registro fue creado o modificado offline y aún no confirmado por el servidor. |
| created_at | TIMESTAMP | NO | CURRENT_TIMESTAMP | Fecha de creación del registro. |
| updated_at | TIMESTAMP | NO | CURRENT_TIMESTAMP | Fecha de última actualización del registro. |

## Relaciones

| Columna | Referencia | Descripción |
|---------|------------|-------------|
| id_movement | movements.id_movement | Operación de movimiento madre a la que pertenece este animal. Si se borra la operación, se borran en cascada sus detalles por animal. |
| id_ranch_animal | ranch_animals.id_ranch_animal | Animal cuya participación se está registrando en el movimiento. |
| id_lot_origin | ranch_lots.id_lot | Lote en el que estaba el animal antes del movimiento. |
| id_lot_dest | ranch_lots.id_lot | Lote al que se traslada el animal (solo `pasture_transfer`). |
| id_event | animal_events.id_animal_event | Evento de animal creado por el servidor al confirmar la operación. |

## Reglas de negocio

- Estados por animal: `pending` (incluido en el movimiento, animal en `id_status=4` Pendiente de Movimiento), `accepted` (en venta/ranch_exit, animal pasa a `id_status=5` Vendido + `id_productive_status=4` Baja), `rejected` (animal revierte a `prev_id_status` y permanece disponible en la estancia), `confirmed` (operación finalizada para `pasture_transfer`/`purchase`/`ranch_exit`).
- `prev_id_status` siempre lo setea el servidor al procesar la operación o el sync — el cliente nunca lo envía. Es la base del rollback al cancelar o rechazar.
- `id_event` permanece NULL mientras el movimiento está en `status=pending`, y también permanece NULL si el animal es rechazado (un rechazo no genera evento de animal).
- En `purchase`, `id_lot_origin` es NULL porque el animal recién ingresa al sistema, sin lote previo.
- En `pasture_transfer`, tanto `id_lot_origin` como `id_lot_dest` se completan, reflejando el traslado entre lotes.

## Notas técnicas

- `status` restringido por CHECK a `'pending'`, `'accepted'`, `'rejected'`, `'confirmed'`.
- `id_movement` tiene `ON DELETE CASCADE`: al eliminar la operación madre se eliminan sus detalles por animal.
- `local_id` tiene constraint UNIQUE para soportar create/update idempotente en sincronización offline: si el `local_id` no existe en el servidor se hace INSERT, si ya existe se hace UPDATE (status, notes).
- El `data.sql` de esta tabla está vacío (`-- sin datos iniciales`) porque es una tabla transaccional, sin catálogo semilla.
