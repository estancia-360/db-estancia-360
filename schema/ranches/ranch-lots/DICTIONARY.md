# ranch_lots

Representa un grupo de animales dentro de un potrero. Es la unidad de manejo operativo del sistema: pesajes, traslados y alimentación se gestionan a nivel de lote.

## Columnas

| Columna | Tipo | Nulo | Default | Descripción |
|---------|------|------|---------|-------------|
| id_lot | BIGSERIAL | NO | autoincremental | Identificador único del lote |
| id_ranch | INT | SÍ | — | Estancia a la que pertenece el lote |
| id_ranch_pasture | BIGINT | NO | — | Potrero físico donde se encuentra el lote |
| name | VARCHAR(50) | NO | — | Nombre del lote |
| lot_type | VARCHAR(30) | SÍ | — | Tipo de lote según etapa productiva que maneja: cria, recria, engorde, reproductiva o general |
| capacity | INT | SÍ | — | Número máximo de animales que el lote puede contener; NULL significa sin límite definido |
| is_active | BOOLEAN | NO | TRUE | Indica si el lote está activo; en FALSE el lote fue cerrado y ya no acepta nuevos animales |
| updated_at | TIMESTAMP | NO | — | Fecha de última modificación del registro |
| created_at | TIMESTAMP | NO | — | Fecha de creación del lote |
| local_id | VARCHAR(100) | SÍ | — | Identificador generado en el dispositivo móvil para sincronización offline; único, permite idempotencia al sincronizar |

## Relaciones

| Columna | Referencia | Descripción |
|---------|------------|-------------|
| id_ranch | ranches.id_ranch | Estancia dueña del lote |
| id_ranch_pasture | ranch_pastures.id_ranch_pasture | Potrero donde está ubicado físicamente el lote |

## Reglas de negocio

- El tipo de lote (lot_type) determina qué módulo productivo puede operar sobre él: lotes 'recria' son destino de weanings.id_lot_dest y rearing_selections.id_lot_dest; lotes 'engorde' son destino de fattening_entries.
- Los módulos solo operan sobre un lote si la estancia tiene habilitado el rubro productivo correspondiente en ranch_production_types.
- Al asignar un animal a un lote se debe verificar que el lote sea del tipo correcto para la etapa productiva del animal y que la estancia tenga ese rubro activo.
- RN-15: el id_lot_dest de un destete debe ser un lote de tipo 'recria'.

## Notas técnicas

- lot_type tiene un CHECK constraint que restringe los valores a: 'cria', 'recria', 'engorde', 'reproductiva', 'general'.
- local_id tiene constraint UNIQUE y fue agregado mediante ALTER TABLE posterior a la creación original; soporta el patrón offline-first de idempotencia en sincronización.
