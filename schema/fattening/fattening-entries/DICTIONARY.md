# fattening_entries

Registra el ingreso formal de un animal al ciclo de Engorde. Un animal llega a Engorde desde Recría (vía `rearing_selections` con `destination='fattening'`) o por compra directa de un animal que ya entra en estado Engorde.

## Columnas

| Columna | Tipo | Nulo | Default | Descripción |
|---------|------|------|---------|-------------|
| id_entry | BIGSERIAL | NO | autoincremental | Identificador único del ingreso a engorde. |
| id_event | BIGINT | NO | — | Evento de animal asociado a este ingreso. |
| system_type | VARCHAR(20) | NO | — | Sistema de engorde: `field` (campo abierto) o `feedlot` (corral de engorde). |
| initial_weight | NUMERIC(6,2) | SÍ | — | Peso del animal al iniciar el ciclo de engorde; base para calcular la ganancia posterior. |
| notes | TEXT | SÍ | — | Observaciones adicionales sobre el ingreso. |
| created_at | TIMESTAMP | NO | CURRENT_TIMESTAMP | Fecha de creación del registro. |
| updated_at | TIMESTAMP | NO | CURRENT_TIMESTAMP | Fecha de última actualización del registro. |

## Relaciones

| Columna | Referencia | Descripción |
|---------|------------|-------------|
| id_event | animal_events.id_animal_event | Evento que originó el ingreso del animal al ciclo de Engorde. |

## Reglas de negocio

- Un animal pasa a Engorde solo si está en Recría (ps=2) y la estancia tiene el rubro Engorde habilitado en `ranch_production_types` (RN-09).
- Al registrar el ingreso, el backend actualiza `ranch_animals.id_productive_status=3` (Engorde).
- Los valores válidos de `system_type` en base de datos son exactamente `'field'` y `'feedlot'` (no se usan equivalentes en español).
- La ganancia de peso posterior se calcula a partir de `weight_records` menos `initial_weight`; no se almacena, se calcula al consultar.
- La conversión alimenticia del ciclo se calcula combinando `feed_records.quantity` del lote y la ganancia de peso (`weight_records`) del animal en el período.
- La salida comercial del animal (venta) se registra en el módulo Movimientos; el retiro sanitario que puede bloquear esa venta proviene de `treatments.withdrawal_end_date`.

## Notas técnicas

- `system_type` restringido por CHECK a `'field'`, `'feedlot'`.
- El `data.sql` de esta tabla está vacío porque es una tabla transaccional, sin catálogo semilla.
