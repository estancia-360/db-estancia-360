# animal_events

Tabla pivot central del sistema. Cada acción que ocurre sobre un animal genera primero un registro aquí; luego la tabla de detalle del módulo correspondiente referencia este evento.

## Columnas

| Columna | Tipo | Nulo | Default | Descripción |
|---------|------|------|---------|-------------|
| id_animal_event | BIGSERIAL | NO | autoincremental | Identificador único del evento |
| id_user | BIGINT | SÍ | — | Usuario responsable de registrar el evento |
| id_ranch_animal | INT | SÍ | — | Animal sobre el que ocurre el evento |
| id_event_type | INT | SÍ | — | Tipo de evento registrado (servicio, diagnóstico, parto, destete, pesaje, etc.) |
| notes | TEXT | SÍ | — | Observación libre del operador de campo |
| is_synced | BOOLEAN | NO | FALSE | Indica si el evento ya fue sincronizado con el servidor central; FALSE mientras está pendiente de envío desde el dispositivo offline |
| event_date | TIMESTAMP | NO | — | Fecha real en que ocurrió el evento en el campo (puede diferir de created_at por el registro offline) |
| updated_at | TIMESTAMP | NO | CURRENT_TIMESTAMP | Fecha de última modificación del registro |
| created_at | TIMESTAMP | NO | CURRENT_TIMESTAMP | Fecha en que el evento fue creado en el sistema |

## Relaciones

| Columna | Referencia | Descripción |
|---------|------------|-------------|
| id_ranch_animal | ranch_animals.id_ranch_animal | Animal afectado por el evento |
| id_event_type | event_types.id_event_type | Tipo de acción registrada: 1=service, 2=diagnosis, 3=birth, 4=weaning, 5=weight_record, 6=rearing_selection, 7=purchase, 8=sale, 9=transfer, 10=exit, 11=vaccination, 12=treatment, 13=health_incident, 14=fattening_entry |
| id_user | users.id_user | Usuario que registró el evento, para trazabilidad de responsabilidad |

## Reglas de negocio

- Todo evento es inmutable una vez creado; las correcciones se realizan creando un nuevo evento, nunca editando uno existente.
- Todo evento debe registrar el usuario responsable (id_user).
- Todo cambio de estado productivo del animal genera automáticamente un registro en esta tabla.
- Al crear cualquier evento, el backend debe verificar que id_ranch_animal existe, pertenece a la estancia del usuario, y que el animal NO está en estado productivo Baja (id_productive_status=4).
- Patrón obligatorio: animal_events (cabecera) se crea siempre antes que la tabla de detalle del módulo (cuerpo), dentro de la misma transacción.

## Notas técnicas

- Es referenciada por las tablas de detalle de todos los módulos productivos: Cría (breeding_services, gestation_diagnoses, parturitions, weanings), Recría (weight_records, rearing_selections), Movimientos (animal_purchases, animal_sales, animal_transfers, animal_exits), Sanidad (vaccinations, treatments, health_incidents) y Engorde (fattening_entries).
- is_synced es el punto único de control para la sincronización offline de todo el sistema.
