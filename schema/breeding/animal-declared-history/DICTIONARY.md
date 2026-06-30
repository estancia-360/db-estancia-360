# animal_declared_history

Historial productivo previo declarado de un animal, usado cuando ingresa al sistema con historia anterior a la digitalización (ej. una vaca comprada o ya existente en la estancia).

## Columnas

| Columna | Tipo | Nulo | Default | Descripción |
|---------|------|------|---------|-------------|
| id_history | BIGSERIAL | NO | autoincremental | Identificador único del historial declarado |
| id_ranch_animal | BIGINT | NO | — | Animal al que pertenece este historial declarado |
| prev_births_count | INT | SÍ | — | Cantidad de partos que tuvo el animal antes de entrar al sistema |
| prev_last_birth_year | INT | SÍ | — | Año del último parto previo a la digitalización |
| prev_avg_weaning_weight | DECIMAL(6,2) | SÍ | — | Peso promedio al destete de las crías anteriores del animal (kg) |
| notes | TEXT | SÍ | — | Observaciones adicionales declaradas por el operador |
| updated_at | TIMESTAMP | SÍ | CURRENT_TIMESTAMP | Fecha de última modificación del registro |
| created_at | TIMESTAMP | SÍ | CURRENT_TIMESTAMP | Fecha de creación del registro |
| local_id | VARCHAR(100) | SÍ | — | Identificador generado en el dispositivo móvil para sincronización offline; único, permite idempotencia al sincronizar |

## Relaciones

| Columna | Referencia | Descripción |
|---------|------------|-------------|
| id_ranch_animal | ranch_animals.id_ranch_animal | Animal cuyo historial productivo previo se declara |

## Reglas de negocio

- Un animal puede tener 0 o 1 registros en esta tabla.
- Es de carácter referencial: no se usa para calcular indicadores actuales del sistema (ej. tasa de preñez), los cuales se calculan solo sobre eventos registrados en el sistema.
- No genera un animal_event, ya que no forma parte del ciclo productivo activo del animal.
- Se usa típicamente al registrar una vaca comprada o al inicializar el sistema en una estancia ya existente.

## Notas técnicas

- local_id tiene constraint UNIQUE (nullable) y fue agregado mediante ALTER TABLE posterior a la creación original; soporta el patrón offline-first de idempotencia en sincronización.
