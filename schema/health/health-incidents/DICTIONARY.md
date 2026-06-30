# health_incidents

Registra eventos sanitarios sobre un animal que no son vacunaciones ni tratamientos directos: detección de enfermedades y declaración de cuarentena. La mortalidad no se registra aquí, sino en `animal_exits` (módulo Movimientos).

## Columnas

| Columna | Tipo | Nulo | Default | Descripción |
|---------|------|------|---------|-------------|
| id_incident | BIGSERIAL | NO | autoincremental | Identificador único del incidente. |
| id_event | BIGINT | NO | — | Evento de animal asociado a este incidente. |
| incident_type | VARCHAR(30) | NO | — | Tipo de incidente: `illness_detected` o `quarantine`. |
| description | VARCHAR(300) | SÍ | — | Descripción del incidente (síntomas, observaciones). |
| resolved_at | DATE | SÍ | — | Fecha en que se resolvió el incidente; NULL si sigue activo. |
| notes | TEXT | SÍ | — | Notas adicionales del responsable. |
| created_at | TIMESTAMP | NO | CURRENT_TIMESTAMP | Fecha de creación del registro. |
| updated_at | TIMESTAMP | NO | CURRENT_TIMESTAMP | Fecha de última actualización del registro. |

## Relaciones

| Columna | Referencia | Descripción |
|---------|------------|-------------|
| id_event | animal_events.id_animal_event | Evento que originó el registro del incidente sanitario. |

## Reglas de negocio

- Todo incidente debe asociarse a un animal específico (RN-17).
- `incident_type='illness_detected'`: registra la detección de una enfermedad o síntoma; puede ir seguido de un `treatment`.
- `incident_type='quarantine'`: el animal se separa del resto del lote por riesgo sanitario. El backend actualiza `ranch_animals.id_status=2` (En Observación) al registrarlo.
- Al marcar `resolved_at`, si el animal estaba en cuarentena, el backend revierte `ranch_animals.id_status=1` (Activo).

## Notas técnicas

- `incident_type` restringido por CHECK a `'illness_detected'`, `'quarantine'`.
- El `data.sql` de esta tabla está vacío porque es una tabla transaccional, sin catálogo semilla.
