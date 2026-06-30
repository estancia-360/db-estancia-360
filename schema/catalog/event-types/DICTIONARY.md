# event_types

Catálogo de los tipos de evento posibles sobre un animal. Cada registro de `animal_events` tiene un `id_event_type` que determina a qué tabla de detalle corresponde el evento (servicio, parto, pesaje, venta, etc.).

## Columnas

| Columna | Tipo | Nulo | Default | Descripción |
|---------|------|------|---------|-------------|
| id_event_type | INT | NO | — | Identificador del tipo de evento |
| name | VARCHAR(50) | NO | — | Nombre del tipo de evento |
| is_active | BOOLEAN | NO | TRUE | Indica si el tipo de evento está disponible para registrarse |

## Reglas de negocio

- Patrón "Event-First": toda acción sobre un animal crea primero un registro en `animal_events` con el `id_event_type` correspondiente, y luego el detalle específico en la tabla del módulo.
- Valores fijos y su tabla de detalle asociada: 1=Servicio de monta (breeding_services), 2=Diagnóstico de gestación (gestation_diagnoses), 3=Parto (parturitions), 4=Destete (weanings), 5=Registro de peso (weight_records), 6=Selección de recría (rearing_selections), 7=Compra (movements/movement_animals), 8=Venta (movements/movement_animals), 9=Transferencia (movements/movement_animals), 10=Salida (movements/movement_animals o animal_exits), 11=Vacunación (vaccinations), 12=Tratamiento (treatments), 13=Incidente sanitario (health_incidents), 14=Entrada a engorde (fattening_entries).

## Notas técnicas

- `id_event_type` no es `SERIAL`: los valores son fijos (1-14) y se insertan explícitamente, coincidiendo con la constante `EVENT_TYPE_IDS` usada en el backend.
