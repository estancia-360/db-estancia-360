# weight_records

Registra los pesajes periódicos de los animales, compartidos entre los módulos Recría y Engorde. Cada fila es un punto de peso en el tiempo para un animal específico.

## Columnas

| Columna | Tipo | Nulo | Default | Descripción |
|---------|------|------|---------|-------------|
| id_weight | BIGSERIAL | NO | autoincremental | Identificador único del pesaje. |
| id_event | BIGINT | NO | — | Evento de animal asociado a este pesaje (acción registrada sobre el animal). |
| id_lot | BIGINT | NO | — | Lote del animal en el momento del pesaje, usado para calcular promedios y rankings por lote. |
| local_id | VARCHAR(100) | SÍ | — | Identificador generado por el cliente offline para evitar pesajes duplicados al sincronizar. |
| weight | NUMERIC(6,2) | NO | — | Peso del animal en kilogramos. |
| weight_type | VARCHAR(20) | NO | — | Forma en que se obtuvo el peso: `scale` (balanza) o `estimated` (estimado visualmente). |
| body_condition | SMALLINT | SÍ | — | Condición corporal del animal en escala 1 a 5 (escala BCS ganadera). |
| age_days | INT | SÍ | — | Edad del animal en días al momento del pesaje. |
| notes | TEXT | SÍ | — | Observaciones adicionales del pesaje. |
| created_at | TIMESTAMP | NO | CURRENT_TIMESTAMP | Fecha de creación del registro. |
| updated_at | TIMESTAMP | NO | CURRENT_TIMESTAMP | Fecha de última actualización del registro. |

## Relaciones

| Columna | Referencia | Descripción |
|---------|------------|-------------|
| id_event | animal_events.id_animal_event | Evento que originó el pesaje; todo pesaje nace de un evento de animal. |
| id_lot | ranch_lots.id_lot | Lote en el que se encontraba el animal al momento de pesarlo. |

## Reglas de negocio

- El animal debe estar en estado productivo Recría o Engorde (ps=2 o ps=3); también se permite en Cría (ps=1) para el pesaje obligatorio a los 120 días.
- `id_lot` debe ser el lote actual del animal al momento del pesaje; si el cliente no lo envía, el backend lo toma de `ranch_animals.idLot`.
- Al crear un pesaje, el backend actualiza `ranch_animals.weight` con el nuevo valor.
- Al borrar un pesaje, el peso del animal se revierte al pesaje inmediato anterior por `event_date`; si no existe uno previo, `ranch_animals.weight` queda en `null`.
- ADG (Ganancia Diaria de Peso) se calcula como `(peso_actual - peso_anterior) / días_entre_pesajes`, siempre al momento de la consulta — no se almacena.
- Alimenta indicadores de Recría (ADG, peso promedio del lote, ranking) y de Engorde (pesajes de control, ganancia diaria, conversión alimenticia junto con `feed_records`).
- Los 3 pesajes recomendados en Cría (nacimiento/120 días/destete) no se fuerzan como bloqueo obligatorio, por ser incompatible con el funcionamiento offline-first.

## Notas técnicas

- `local_id` tiene constraint UNIQUE para soportar idempotencia en sincronización offline (agregado en migración del 2026-04-14).
- `weight_type` restringido por CHECK a `'scale'` o `'estimated'`.
- `body_condition` restringido por CHECK al rango 1-5.
