# vaccinations

Registra las vacunas aplicadas a un animal, en cualquier etapa productiva (Cría, Recría, Engorde). También cubre la aplicación de antiparasitarios que no tienen período de retiro.

## Columnas

| Columna | Tipo | Nulo | Default | Descripción |
|---------|------|------|---------|-------------|
| id_vaccination | BIGSERIAL | NO | autoincremental | Identificador único de la vacunación. |
| id_event | BIGINT | NO | — | Evento de animal asociado a esta vacunación. |
| vaccine_name | VARCHAR(150) | NO | — | Nombre de la vacuna o antiparasitario aplicado. |
| dose | VARCHAR(50) | SÍ | — | Dosis aplicada (ej. "5ml", "2cc"). |
| responsible | VARCHAR(150) | SÍ | — | Nombre del responsable o veterinario que aplicó la vacuna. |
| notes | TEXT | SÍ | — | Observaciones adicionales. |
| created_at | TIMESTAMP | NO | CURRENT_TIMESTAMP | Fecha de creación del registro. |
| updated_at | TIMESTAMP | NO | CURRENT_TIMESTAMP | Fecha de última actualización del registro. |

## Relaciones

| Columna | Referencia | Descripción |
|---------|------------|-------------|
| id_event | animal_events.id_animal_event | Evento que originó el registro de la vacunación. |

## Reglas de negocio

- Todo registro sanitario debe asociarse a un animal específico (RN-17).
- Debe registrarse como mínimo la vacuna, la dosis y el responsable.
- Para antiparasitarios que tienen período de retiro antes de poder vender al animal, debe usarse `treatments` en lugar de esta tabla.

## Notas técnicas

- El `data.sql` de esta tabla está vacío porque es una tabla transaccional, sin catálogo semilla.
