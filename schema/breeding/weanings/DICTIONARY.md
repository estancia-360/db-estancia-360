# weanings

Registra el destete de una cría. Es el evento que finaliza el ciclo de Cría y da inicio al de Recría; es el único mecanismo para que un animal pase a la etapa productiva Recría.

## Columnas

| Columna | Tipo | Nulo | Default | Descripción |
|---------|------|------|---------|-------------|
| id_weaning | BIGSERIAL | NO | autoincremental | Identificador único del destete |
| id_event | bigint | NO | — | Evento asociado a este destete, registrado sobre el animal cría (no sobre la madre) |
| id_cria | bigint | NO | — | Animal que se desteta |
| id_lot_dest | bigint | NO | — | Lote de recría al que ingresa la cría después del destete |
| weaning_weight | numeric(6,2) | SÍ | — | Peso de la cría al momento del destete; indicador clave del módulo Cría |
| weaning_age | int | SÍ | — | Edad en días de la cría al destete; indicador de "edad al primer destete" |
| updated_at | TIMESTAMP | NO | CURRENT_TIMESTAMP | Fecha de última modificación del registro |
| created_at | TIMESTAMP | NO | CURRENT_TIMESTAMP | Fecha de creación del registro |
| local_id | VARCHAR(100) | SÍ | — | Identificador generado en el dispositivo móvil para sincronización offline; único, permite idempotencia al sincronizar |

## Relaciones

| Columna | Referencia | Descripción |
|---------|------------|-------------|
| id_event | animal_events.id_animal_event | Evento que registra el destete, asociado al animal cría (tipo 'weaning') |
| id_cria | ranch_animals.id_ranch_animal | Animal que es destetado |
| id_lot_dest | ranch_lots.id_lot | Lote de recría destino del animal tras el destete |

## Reglas de negocio

- Solo mediante un destete registrado un animal pasa a la etapa productiva Recría; no existe otro camino.
- La cría debe tener id_productive_status=1 (Cría) para poder ser destetada.
- RN-15: id_lot_dest debe ser un lote de tipo 'recria' y pertenecer a una estancia con el rubro Recría habilitado.
- RN-19: la edad de destete debe estar entre un mínimo de 120 días y un máximo de 300 días.
- Al registrar el destete, el backend actualiza automáticamente en ranch_animals de la cría: id_productive_status=2 (Recría) e id_lot=id_lot_dest.
- Se debe registrar fecha, peso al destete, edad en días y lote destino.
- Flujo del módulo Cría: breeding_services → gestation_diagnoses → parturitions → weanings.

## Notas técnicas

- id_event tiene ON DELETE CASCADE; id_cria e id_lot_dest también tienen ON DELETE CASCADE.
- El id_ranch_animal del animal_event asociado apunta a la cría, no a la madre, a pesar de que el ciclo reproductivo (servicio, diagnóstico, parto) se registra sobre la madre.
- local_id tiene constraint UNIQUE (nullable) y fue agregado mediante ALTER TABLE posterior a la creación original; soporta el patrón offline-first de idempotencia en sincronización.
