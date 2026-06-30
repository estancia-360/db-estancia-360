# rearing_selections

Registra la decisión de destino de un animal al finalizar la etapa de Recría: reposición (se queda como reproductor), engorde (inicia ciclo de terminación) o venta directa.

## Columnas

| Columna | Tipo | Nulo | Default | Descripción |
|---------|------|------|---------|-------------|
| id_selection | BIGSERIAL | NO | autoincremental | Identificador único de la selección. |
| id_event | BIGINT | NO | — | Evento de animal asociado a esta selección. |
| id_lot_dest | BIGINT | SÍ | — | Lote destino del animal, obligatorio solo si `destination='fattening'`. |
| local_id | VARCHAR(100) | SÍ | — | Identificador generado por el cliente offline para idempotencia al sincronizar. |
| destination | VARCHAR(20) | NO | — | Destino decidido para el animal: `replacement`, `fattening` o `sale`. |
| weight_at_selection | NUMERIC(6,2) | SÍ | — | Peso del animal al momento de la selección. |
| body_condition | SMALLINT | SÍ | — | Condición corporal en escala 1 a 5. |
| genetic_score | NUMERIC(5,2) | SÍ | — | Puntaje genético asignado por el criador. |
| age_days | INT | SÍ | — | Edad del animal en días al momento de la selección. |
| notes | TEXT | SÍ | — | Observaciones adicionales sobre la selección. |
| created_at | TIMESTAMP | NO | CURRENT_TIMESTAMP | Fecha de creación del registro. |
| updated_at | TIMESTAMP | NO | CURRENT_TIMESTAMP | Fecha de última actualización del registro. |

## Relaciones

| Columna | Referencia | Descripción |
|---------|------------|-------------|
| id_event | animal_events.id_animal_event | Evento que originó la selección de destino. |
| id_lot_dest | ranch_lots.id_lot | Lote al que se traslada el animal cuando el destino es engorde (o reposición, si corresponde). |

## Reglas de negocio

- `destination='replacement'`: el animal permanece en la estancia y su estado productivo sigue en Recría (ps=2) hasta su primer `breeding_service`; no cambia `ps`.
- `destination='fattening'`: requiere que la estancia tenga el rubro Engorde habilitado (RN-09) y que el animal esté en ps=2. El backend crea automáticamente un `fattening_entry` (event_type=14) dentro de la misma transacción, actualiza `ranch_animals.id_productive_status=3` y `ranch_animals.id_lot=id_lot_dest`. `id_lot_dest` es obligatorio en este caso.
- `destination='sale'`: actualiza `ranch_animals.id_productive_status=4` y `id_status=3`. Es irreversible (RN-07). Aún no crea un registro en el módulo Movimientos (pendiente de implementación).
- Si la selección con destino `fattening` se elimina, debe revertirse: `ranch_animals.id_productive_status=2` y eliminarse el `fattening_entry` asociado.

## Notas técnicas

- `local_id` tiene constraint UNIQUE para idempotencia offline (agregado en migración del 2026-04-14).
- `destination` restringido por CHECK a `'replacement'`, `'fattening'`, `'sale'`.
- `body_condition` restringido por CHECK al rango 1-5.
- `id_lot_dest` es nullable a nivel de base de datos; la obligatoriedad condicional según `destination` se valida en la capa de aplicación.
