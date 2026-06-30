# parturitions

Registra el parto de una vaca. Requiere un diagnóstico de gestación previo con resultado positivo; si la cría nace viva, el sistema crea automáticamente un nuevo animal.

## Columnas

| Columna | Tipo | Nulo | Default | Descripción |
|---------|------|------|---------|-------------|
| id_parturition | BIGSERIAL | NO | autoincremental | Identificador único del parto |
| id_event | bigint | NO | — | Evento asociado a este parto, registrado sobre la vaca madre |
| id_diagnosis | bigint | NO | — | Diagnóstico de gestación que habilita este parto |
| birth_type | varchar(20) | NO | — | Tipo de parto: normal, assisted (asistido) o cesarean (cesárea) |
| id_cria | BIGINT | SÍ | — | Animal recién nacido creado a partir de este parto; NULL si la cría nació muerta |
| cria_weight | NUMERIC(6,2) | SÍ | — | Peso de la cría al nacer, en kg |
| cria_status | varchar(20) | NO | — | Estado de la cría al nacer: alive (viva) o dead (muerta) |
| mother_condition | varchar(20) | SÍ | — | Condición de la madre después del parto: good, regular o bad |
| updated_at | TIMESTAMP | NO | CURRENT_TIMESTAMP | Fecha de última modificación del registro |
| created_at | TIMESTAMP | NO | CURRENT_TIMESTAMP | Fecha de creación del registro |
| local_id | VARCHAR(100) | SÍ | — | Identificador generado en el dispositivo móvil para sincronización offline; único, permite idempotencia al sincronizar |

## Relaciones

| Columna | Referencia | Descripción |
|---------|------------|-------------|
| id_event | animal_events.id_animal_event | Evento que registra el parto, asociado al animal madre (tipo 'birth') |
| id_diagnosis | gestation_diagnoses.id_diagnosis | Diagnóstico de gestación que habilitó este parto |
| id_cria | ranch_animals.id_ranch_animal | Animal recién nacido creado automáticamente si la cría nació viva |

## Reglas de negocio

- RN-12: no puede registrarse un parto sin un gestation_diagnosis con result='pregnant' asociado a la misma vaca, y ese diagnóstico no debe tener ya un parto asociado.
- RN-14: relación 1:1 entre diagnóstico y parto — un diagnóstico solo puede generar un parto.
- Si cria_status='alive', el backend debe crear automáticamente un registro en ranch_animals para la cría, con id_mother=madre del parto, id_productive_status=1 y id_ranch=misma estancia, y guardar ese id en parturitions.id_cria.
- RN-11: toda cría viva debe vincularse a la madre mediante id_mother NOT NULL en ranch_animals.
- Si cria_status='dead', el parto se crea con id_cria=NULL.
- Flujo del módulo Cría: breeding_services → gestation_diagnoses → parturitions → weanings.

## Notas técnicas

- birth_type tiene un CHECK constraint que restringe los valores a: 'normal', 'assisted', 'cesarean'.
- cria_status tiene un CHECK constraint que restringe los valores a: 'alive', 'dead'.
- mother_condition tiene un CHECK constraint que restringe los valores a: 'good', 'regular', 'bad'.
- id_event, id_diagnosis e id_cria tienen ON DELETE CASCADE.
- local_id tiene constraint UNIQUE (nullable) y fue agregado mediante ALTER TABLE posterior a la creación original; soporta el patrón offline-first de idempotencia en sincronización.
