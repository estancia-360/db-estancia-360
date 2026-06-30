# feed_records

Registra el suministro de alimento a un lote de animales en el módulo Engorde. Es la única tabla transaccional del sistema que no pasa por `animal_events`, porque la alimentación se gestiona a nivel de lote y no por animal individual.

## Columnas

| Columna | Tipo | Nulo | Default | Descripción |
|---------|------|------|---------|-------------|
| id_feed | BIGSERIAL | NO | autoincremental | Identificador único del registro de alimentación. |
| id_lot | BIGINT | NO | — | Lote al que se suministró el alimento. |
| id_user | BIGINT | SÍ | — | Usuario que registró el suministro. |
| local_id | VARCHAR(100) | SÍ | — | Identificador generado por el cliente offline para idempotencia al sincronizar. |
| feed_date | DATE | NO | — | Fecha del suministro de alimento. |
| feed_type | VARCHAR(150) | NO | — | Tipo de alimento suministrado (texto libre: maíz, balanceado, heno, etc.). |
| quantity | NUMERIC(10,2) | SÍ | — | Cantidad de alimento suministrada. |
| unit | VARCHAR(20) | SÍ | — | Unidad de medida (kg, bolsas, fardos; NULL implica kg por defecto). |
| cost | NUMERIC(10,2) | SÍ | — | Costo total del suministro (indicador económico). |
| notes | TEXT | SÍ | — | Observaciones adicionales. |
| is_synced | BOOLEAN | NO | FALSE | Indica si el registro creado offline ya fue sincronizado al servidor. |
| created_at | TIMESTAMP | NO | CURRENT_TIMESTAMP | Fecha de creación del registro. |
| updated_at | TIMESTAMP | NO | CURRENT_TIMESTAMP | Fecha de última actualización del registro. |

## Relaciones

| Columna | Referencia | Descripción |
|---------|------------|-------------|
| id_lot | ranch_lots.id_lot | Lote de animales al que se le suministró el alimento. |
| id_user | users.id_user | Usuario responsable de registrar el suministro. |

## Reglas de negocio

- El lote debe ser de tipo `fattening` para registrar alimentación de Engorde; también puede usarse para lotes `rearing` si corresponde.
- Al no estar vinculada a `animal_events`, esta tabla mantiene su propio campo `is_synced` para el seguimiento de sincronización offline.
- La conversión alimenticia de un lote en un período se calcula como `consumo_total (SUM de quantity) / ganancia_total (SUM de delta de peso vía weight_records)`; el cálculo lo hace el backend al consultar indicadores de Engorde, no se almacena.

## Notas técnicas

- `local_id` tiene constraint UNIQUE para idempotencia offline (agregado en migración del 2026-05-13).
- El `data.sql` de esta tabla está vacío porque es una tabla transaccional, sin catálogo semilla.
