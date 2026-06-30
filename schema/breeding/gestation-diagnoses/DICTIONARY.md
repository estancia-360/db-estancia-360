# gestation_diagnoses

Registra el diagnóstico de gestación de una vaca después de un servicio reproductivo. Es el paso que habilita el registro de un parto.

## Columnas

| Columna | Tipo | Nulo | Default | Descripción |
|---------|------|------|---------|-------------|
| id_diagnosis | SERIAL | NO | autoincremental | Identificador único del diagnóstico |
| id_event | bigint | NO | — | Evento asociado a este diagnóstico dentro del historial del animal |
| id_service | bigint | NO | — | Servicio reproductivo del que deriva este diagnóstico |
| method | varchar(20) | NO | — | Método de diagnóstico utilizado: palpation (palpación rectal) o ultrasound (ecografía) |
| result | varchar(20) | NO | — | Resultado del diagnóstico: pregnant (preñada) o empty (vacía) |
| gestation_days | int | SÍ | — | Días estimados de gestación al momento del diagnóstico |
| estimated_birth | date | SÍ | — | Fecha estimada de parto, calculada por el veterinario |
| veterinarian | varchar(150) | SÍ | — | Nombre del veterinario responsable del diagnóstico |
| updated_at | TIMESTAMP | NO | CURRENT_TIMESTAMP | Fecha de última modificación del registro |
| created_at | TIMESTAMP | NO | CURRENT_TIMESTAMP | Fecha de creación del registro |
| local_id | VARCHAR(100) | SÍ | — | Identificador generado en el dispositivo móvil para sincronización offline; único, permite idempotencia al sincronizar |

## Relaciones

| Columna | Referencia | Descripción |
|---------|------------|-------------|
| id_event | animal_events.id_animal_event | Evento que registra este diagnóstico sobre la vaca (tipo 'diagnosis') |
| id_service | breeding_services.id_service | Servicio reproductivo del cual deriva este diagnóstico |

## Reglas de negocio

- RN-12: no puede registrarse un parto (parturitions) sin que exista un gestation_diagnosis con result='pregnant' asociado.
- Se debe registrar siempre método, resultado, días estimados de gestación, fecha estimada de parto y nombre del veterinario.
- Una vaca puede tener múltiples diagnósticos en su vida (uno por ciclo reproductivo); solo el más reciente con result='pregnant' sin parto asociado se considera "activo" para efectos de RN-13.
- Se permiten múltiples diagnósticos por servicio (no hay restricción de unicidad), ya que en la práctica el veterinario puede repetir el diagnóstico en campo.
- Si result='pregnant', el ciclo se considera activo de forma dinámica (consultado en validación, no almacenado). Si result='empty', el animal puede recibir un nuevo servicio.

## Notas técnicas

- method tiene un CHECK constraint que restringe los valores a: 'palpation', 'ultrasound'.
- result tiene un CHECK constraint que restringe los valores a: 'pregnant', 'empty'.
- id_event e id_service tienen ON DELETE CASCADE: si se elimina el evento o el servicio asociado, el diagnóstico se elimina en cascada.
- local_id tiene constraint UNIQUE (nullable) y fue agregado mediante ALTER TABLE posterior a la creación original; soporta el patrón offline-first de idempotencia en sincronización.
