# regions

Catálogo de regiones o departamentos dentro de un país. Es el segundo nivel de la jerarquía geográfica del sistema.

## Columnas

| Columna | Tipo | Nulo | Default | Descripción |
|---------|------|------|---------|-------------|
| id_region | SERIAL | NO | autoincremental | Identificador de la región |
| id_country | INT | NO | — | País al que pertenece la región |
| name | VARCHAR(100) | NO | — | Nombre de la región o departamento |
| is_active | BOOLEAN | SÍ | TRUE | Indica si la región está disponible para seleccionarse en nuevos registros |

## Relaciones

| Columna | Referencia | Descripción |
|---------|------------|-------------|
| id_country | countries.id_country | País al que pertenece esta región o departamento |

## Reglas de negocio

- Jerarquía geográfica: countries → regions → cities → ranches.
- Catálogo fijo del sistema; los datos semilla actuales cargan los departamentos de Bolivia (La Paz, Cochabamba, Santa Cruz, Oruro, Potosí, Tarija, Chuquisaca, Beni, Pando).

## Notas técnicas

- `is_active` permite desactivar una región sin eliminar registros históricos que dependan de ella (cities).
