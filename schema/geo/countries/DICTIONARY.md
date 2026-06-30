# countries

Catálogo de países disponibles para el registro de estancias. Es el primer nivel de la jerarquía geográfica del sistema.

## Columnas

| Columna | Tipo | Nulo | Default | Descripción |
|---------|------|------|---------|-------------|
| id_country | SERIAL | NO | autoincremental | Identificador del país |
| name | VARCHAR(100) | NO | — | Nombre del país |
| is_active | BOOLEAN | SÍ | TRUE | Indica si el país está disponible para seleccionarse en nuevos registros |

## Reglas de negocio

- Jerarquía geográfica: countries → regions → cities → ranches. Cada estancia pertenece, en última instancia, a un país a través de su ciudad.
- Catálogo fijo del sistema; los datos semilla incluyen 10 países de Sudamérica (Argentina, Brasil, Uruguay, Paraguay, Bolivia, Chile, Perú, Ecuador, Colombia, Venezuela).

## Notas técnicas

- `is_active` permite desactivar un país sin eliminar registros históricos que dependan de él (regions, cities).
