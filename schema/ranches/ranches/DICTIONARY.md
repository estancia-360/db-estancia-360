# ranches

Representa una unidad productiva ganadera (estancia). Es el contenedor raíz de todos los recursos del sistema: animales, potreros, lotes y usuarios.

## Columnas

| Columna | Tipo | Nulo | Default | Descripción |
|---------|------|------|---------|-------------|
| id_ranch | SERIAL | NO | autoincremental | Identificador único de la estancia |
| id_city | INT | NO | — | Ciudad donde se ubica la estancia (define la jerarquía geográfica país→región→ciudad) |
| name | VARCHAR(200) | NO | — | Nombre de la estancia |
| created_at | TIMESTAMP | SÍ | CURRENT_TIMESTAMP | Fecha de alta de la estancia en el sistema |
| updated_at | TIMESTAMP | SÍ | CURRENT_TIMESTAMP | Fecha de última modificación del registro |

## Relaciones

| Columna | Referencia | Descripción |
|---------|------------|-------------|
| id_city | cities.id_city | Ciudad de ubicación de la estancia, de la cual se deriva región y país |

## Reglas de negocio

- Cada estancia tiene un único dueño (Owner), registrado en ranch_users con id_role=1.
- Toda estancia debe tener al menos un rubro productivo activo (Cría, Recría o Engorde), gestionado en ranch_production_types.
- Los módulos productivos (Cría, Recría, Engorde) solo operan sobre una estancia si su rubro correspondiente está habilitado en ranch_production_types.
- Al crear una estancia, el backend debe: (1) crear el registro en ranches, (2) crear el ranch_users del creador como Owner, (3) crear los ranch_production_types con los rubros seleccionados.

## Notas técnicas

- No tiene columna id_production_type directa: los rubros productivos se modelan en la tabla de unión ranch_production_types para soportar múltiples rubros simultáneos por estancia.
