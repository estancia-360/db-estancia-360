# movements

Representa la operación "madre" de un movimiento de animales (venta, compra, traslado entre potreros o salida hacia otra estancia). Una operación puede involucrar uno o más animales; el detalle individual de cada animal se almacena en `movement_animals`.

## Columnas

| Columna | Tipo | Nulo | Default | Descripción |
|---------|------|------|---------|-------------|
| id_movement | BIGSERIAL | NO | autoincremental | Identificador único de la operación de movimiento. |
| id_ranch | BIGINT | NO | — | Estancia donde ocurre el movimiento. |
| id_user | BIGINT | SÍ | — | Usuario que registra la operación. |
| movement_type | VARCHAR(30) | NO | — | Tipo de operación: `sale`, `purchase`, `pasture_transfer` o `ranch_exit`. |
| movement_date | DATE | NO | — | Fecha efectiva en que ocurre la operación. |
| status | VARCHAR(30) | NO | 'pending' | Estado global de la operación: `pending`, `confirmed` o `cancelled`. |
| counterpart_name | VARCHAR(200) | SÍ | — | Nombre de la contraparte: comprador (en `sale`) o estancia destino (en `ranch_exit`); texto libre, sin FK. |
| origin_name | VARCHAR(200) | SÍ | — | Nombre del proveedor o estancia de origen, usado en `purchase`; texto libre, sin FK. |
| total_price | NUMERIC(12,2) | SÍ | — | Precio total acordado de la operación (`sale`/`purchase`). |
| price_per_kg | NUMERIC(8,2) | SÍ | — | Precio por kilogramo, indicador comercial (`sale`/`purchase`). |
| notes | TEXT | SÍ | — | Observaciones adicionales sobre la operación. |
| local_id | VARCHAR(100) | SÍ | — | Identificador generado por el cliente offline para idempotencia al sincronizar. |
| is_synced | BOOLEAN | NO | FALSE | Indica si el registro creado offline ya fue sincronizado al servidor. |
| created_at | TIMESTAMP | NO | CURRENT_TIMESTAMP | Fecha de creación del registro. |
| updated_at | TIMESTAMP | NO | CURRENT_TIMESTAMP | Fecha de última actualización del registro. |

## Relaciones

| Columna | Referencia | Descripción |
|---------|------------|-------------|
| id_ranch | ranches.id_ranch | Estancia propietaria de la operación de movimiento. |
| id_user | users.id_user | Usuario que registró la operación (debe ser OWNER para `sale`, `purchase` y `ranch_exit`). |

## Reglas de negocio

- Solo el OWNER (ranch_role=1) puede registrar `sale`, `purchase` y `ranch_exit` (RN-01/RN-16).
- `pasture_transfer` no requiere validación de OWNER y no cambia el `id_status` del animal, solo su lote.
- `sale` es la única operación que puede quedar en `status='pending'` tras registrarse; `pasture_transfer`, `purchase` y `ranch_exit` pasan directo a `confirmed` al crearse.
- Flujo `sale`: registrar (animales pasan a `id_status=4` Pendiente de Movimiento, movimiento en `pending`) → confirmar por animal (`accepted`→`id_status=5` Vendido + ps=4 Baja; `rejected`→revierte a `prev_id_status`) → `movements.status='confirmed'`. Si se cancela antes de confirmar, todos los animales revierten a `prev_id_status` y `movements.status='cancelled'`.
- Antes de registrar una venta, el backend debe verificar que ningún animal tenga `treatments.withdrawal_end_date >= hoy` (RN-18); si lo tiene, se bloquea la venta.
- Flujo `purchase`: crea animales nuevos en `ranch_animals` con `origin='purchased'`, los `movement_animals` quedan `confirmed` con `prev_id_status=1`, y el movimiento pasa directo a `confirmed`.
- Flujo `pasture_transfer`: actualiza `ranch_animals.id_lot=id_lot_dest` para cada animal; no cambia el `id_status`.
- Flujo `ranch_exit`: animales pasan a `id_status=5` (Vendido) y `id_productive_status=4` (Baja) — irreversible (RN-07). La estancia destino registra su ingreso de forma independiente como `purchase`, sin existir FK entre estancias; `counterpart_name` guarda el nombre de esa estancia destino como texto libre.
- `sale (accepted)` y `ranch_exit` ambos dejan al animal en ps=4, pero son conceptos comerciales distintos entre sí y distintos de `animal_exits` (muerte/descarte), que deja `id_status=3` Inactivo en lugar de Vendido.

## Notas técnicas

- `movement_type` y `status` están restringidos por CHECK a los valores enumerados.
- Esta tabla y `movement_animals` reemplazan el diseño anterior de `animal_transfers`/`animal_sales`/`animal_purchases` (ver `migrations/2026-05-23_movimientos-module/`); el diseño es batch-first, una operación puede cubrir múltiples animales.
- El `data.sql` de esta tabla está vacío (`-- sin datos iniciales`) porque es una tabla transaccional, sin catálogo semilla.
