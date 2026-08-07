# treatments

Registra tratamientos médicos aplicados a un animal (medicamentos, antibióticos, antiparasitarios con período de retiro). El período de retiro es clave porque bloquea la venta del animal mientras está vigente.

## Columnas

| Columna | Tipo | Nulo | Default | Descripción |
|---------|------|------|---------|-------------|
| id_treatment | BIGSERIAL | NO | autoincremental | Identificador único del tratamiento. |
| id_event | BIGINT | NO | — | Evento de animal asociado a este tratamiento. |
| illness | VARCHAR(150) | SÍ | — | Enfermedad o diagnóstico que motivó el tratamiento. |
| medication | VARCHAR(150) | NO | — | Medicamento aplicado. |
| dose | VARCHAR(50) | SÍ | — | Dosis aplicada. |
| duration_days | INT | SÍ | — | Duración total del tratamiento, en días. |
| withdrawal_days | INT | SÍ | — | Días de retiro sanitario exigidos por el medicamento (0 o NULL = sin retiro). |
| withdrawal_end_date | DATE | SÍ | — | Fecha en que termina el período de retiro; calculada automáticamente por el backend. |
| responsible | VARCHAR(150) | SÍ | — | Veterinario o responsable del tratamiento. |
| notes | TEXT | SÍ | — | Observaciones adicionales. |
| local_id | VARCHAR(100) | SÍ | — | ID generado por el cliente offline, único; permite reintentar el sync sin duplicar el registro. |
| created_at | TIMESTAMP | NO | CURRENT_TIMESTAMP | Fecha de creación del registro. |
| updated_at | TIMESTAMP | NO | CURRENT_TIMESTAMP | Fecha de última actualización del registro. |

## Relaciones

| Columna | Referencia | Descripción |
|---------|------------|-------------|
| id_event | animal_events.id_animal_event | Evento que originó el registro del tratamiento. |

## Reglas de negocio

- Todo tratamiento debe asociarse a un animal específico (RN-17).
- Debe registrarse como mínimo la enfermedad, el medicamento, la dosis, la duración y el responsable.
- `withdrawal_end_date` se calcula automáticamente como `event_date + withdrawal_days` días; el backend lo calcula, el cliente no lo envía.
- No se puede vender un animal si tiene un tratamiento con `withdrawal_end_date >= fecha actual` (RN-18); el backend verifica esta condición antes de confirmar una venta y bloquea la operación si hay coincidencia.

## Notas técnicas

- El `data.sql` de esta tabla está vacío porque es una tabla transaccional, sin catálogo semilla.
