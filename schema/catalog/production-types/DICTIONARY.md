# production_types

Catálogo de los rubros productivos que una estancia puede manejar: Cría, Recría y Engorde. Cada estancia habilita uno o más rubros según su operación.

## Columnas

| Columna | Tipo | Nulo | Default | Descripción |
|---------|------|------|---------|-------------|
| id_type | SERIAL | NO | autoincremental | Identificador del rubro productivo |
| name | VARCHAR(30) | NO | — | Nombre del rubro productivo |
| is_active | BOOLEAN | SÍ | TRUE | Indica si el rubro está disponible para asignarse a una estancia |

## Reglas de negocio

- Se relaciona con las estancias vía `ranch_production_types` (relación muchos a muchos): una estancia puede tener uno o más rubros activos.
- Valores fijos: 1=Cría (módulo reproductivo: breeding_services, parturitions, etc.), 2=Recría (módulo de crecimiento: weight_records, rearing_selections), 3=Engorde (módulo de terminación: fattening_entries, feed_records).
- RN-09: el ingreso a Engorde solo es posible si la estancia tiene el rubro Engorde habilitado y el animal proviene de Recría.

## Notas técnicas

- `is_active` permite desactivar un rubro sin afectar el historial de estancias que ya lo tuvieron habilitado.
