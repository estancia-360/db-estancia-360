# breeding_services

Registra el servicio reproductivo (monta natural, inseminación artificial o transferencia embrionaria) dado a una vaca. Es el primer paso del ciclo reproductivo del módulo Cría.

## Columnas

| Columna | Tipo | Nulo | Default | Descripción |
|---------|------|------|---------|-------------|
| id_service | BIGSERIAL | NO | autoincremental | Identificador único del servicio reproductivo |
| id_event | bigint | NO | — | Evento asociado a este servicio dentro del historial del animal |
| id_animal_male | bigint | SÍ | — | Toro utilizado en el servicio; solo aplica en monta natural, NULL en inseminación artificial |
| service_type | varchar(30) | NO | — | Tipo de servicio reproductivo: natural, artificial_insemination o embryo_transfer |
| semen_breed | varchar(100) | SÍ | — | Raza del semen utilizado; solo aplica en inseminación artificial |
| technician | varchar(150) | SÍ | — | Nombre del técnico responsable; solo aplica en inseminación artificial |
| reproductive_lot | varchar(100) | SÍ | — | Referencia textual libre al lote reproductivo, si aplica |
| updated_at | TIMESTAMP | NO | CURRENT_TIMESTAMP | Fecha de última modificación del registro |
| created_at | TIMESTAMP | NO | CURRENT_TIMESTAMP | Fecha de creación del registro |
| local_id | VARCHAR(100) | SÍ | — | Identificador generado en el dispositivo móvil para sincronización offline; único, permite idempotencia al sincronizar |

## Relaciones

| Columna | Referencia | Descripción |
|---------|------------|-------------|
| id_event | animal_events.id_animal_event | Evento que registra este servicio sobre la vaca servida (tipo 'service') |
| id_animal_male | ranch_animals.id_ranch_animal | Toro utilizado en el servicio natural |

## Reglas de negocio

- RN-13: una vaca con un diagnóstico de gestación 'pregnant' activo no puede recibir un nuevo servicio hasta que ese ciclo reproductivo finalice (por parto o por diagnóstico vacío).
- El animal servido debe ser hembra (sex='F') y estar en etapa productiva Cría (id_productive_status=1).
- En inseminación artificial se deben registrar semen_breed y technician.
- Sin un servicio registrado no se puede realizar diagnóstico ni registrar parto (RN-12).
- Flujo del módulo Cría: breeding_services → gestation_diagnoses → parturitions → weanings.

## Notas técnicas

- service_type tiene un CHECK constraint que restringe los valores a: 'natural', 'artificial_insemination', 'embryo_transfer'.
- id_event y id_animal_male tienen ON DELETE CASCADE: si se elimina el evento o el toro asociado, el servicio se elimina en cascada.
- local_id tiene constraint UNIQUE (nullable) y fue agregado mediante ALTER TABLE posterior a la creación original; soporta el patrón offline-first de idempotencia en sincronización.
