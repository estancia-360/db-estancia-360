# cities

Catálogo de ciudades o municipios dentro de una región. Es el tercer nivel de la jerarquía geográfica del sistema; una estancia pertenece a una ciudad.

## Columnas

| Columna | Tipo | Nulo | Default | Descripción |
|---------|------|------|---------|-------------|
| id_city | SERIAL | NO | autoincremental | Identificador de la ciudad |
| id_region | INT | NO | — | Región a la que pertenece la ciudad |
| name | VARCHAR(100) | NO | — | Nombre de la ciudad o municipio |
| is_active | BOOLEAN | SÍ | TRUE | Indica si la ciudad está disponible para seleccionarse en nuevos registros |

## Relaciones

| Columna | Referencia | Descripción |
|---------|------------|-------------|
| id_region | regions.id_region | Región o departamento al que pertenece esta ciudad |

## Reglas de negocio

- Jerarquía geográfica: countries → regions → cities → ranches. Una estancia (ranches) se ubica en una ciudad.
- Catálogo fijo del sistema; los datos semilla actuales cargan ciudades de las regiones de Bolivia.

## Notas técnicas

- `is_active` permite desactivar una ciudad sin eliminar registros históricos que dependan de ella (ranches).
