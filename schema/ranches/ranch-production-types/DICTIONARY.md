# ranch_production_types

Tabla de unión que define qué rubros productivos (Cría, Recría, Engorde) tiene habilitados cada estancia.

## Columnas

| Columna | Tipo | Nulo | Default | Descripción |
|---------|------|------|---------|-------------|
| id_ranch | INT | NO | — | Estancia a la que se le habilita el rubro productivo |
| id_production_type | INT | NO | — | Rubro productivo habilitado (Cría, Recría o Engorde) |

## Relaciones

| Columna | Referencia | Descripción |
|---------|------------|-------------|
| id_ranch | ranches.id_ranch | Estancia que habilita el rubro |
| id_production_type | production_types.id_type | Tipo de rubro productivo habilitado para esa estancia |

## Reglas de negocio

- Toda estancia debe tener al menos un rubro activo.
- Los módulos productivos solo operan si su rubro correspondiente está registrado aquí para la estancia del animal; de lo contrario la operación debe rechazarse (ej. no se puede crear un fattening_entry si la estancia no tiene Engorde habilitado).
- Antes de permitir cualquier acción de un módulo productivo, el backend debe verificar que el id_production_type correspondiente esté presente en esta tabla para la estancia del animal.

## Notas técnicas

- Clave primaria compuesta (id_ranch, id_production_type): modela una relación ManyToMany entre ranches y production_types sin columna id propia.
