# ranch_animals

Registro de cada animal bovino de la estancia. Es la entidad central del sistema: toda compra, nacimiento, evento sanitario, productivo o de movimiento la referencia.

## Columnas

| Columna | Tipo | Nulo | Default | Descripción |
|---------|------|------|---------|-------------|
| id_ranch_animal | BIGSERIAL | NO | autoincremental | Identificador único del animal |
| id_mother | BIGINT | SÍ | — | Madre del animal, si nació dentro del sistema |
| id_father | BIGINT | SÍ | — | Padre del animal, si se conoce y nació dentro del sistema |
| id_ranch | INT | NO | — | Estancia a la que pertenece el animal |
| id_breed | INT | NO | — | Raza del animal |
| id_status | INT | NO | — | Estado operativo actual del animal (Activo, En Observación, Inactivo, Pendiente de Movimiento o Vendido) |
| id_productive_status | INT | SÍ | — | Etapa productiva actual del animal (Cría, Recría, Engorde o Baja) |
| id_animal_class | INT | NO | — | Clasificación del animal (Ternera, Vaca, Toro, Novillo, etc.), elegida manualmente por el operador |
| id_lot | BIGINT | SÍ | — | Lote al que pertenece actualmente el animal |
| code | VARCHAR(50) | NO | — | Código de caravana del animal, único por estancia |
| birthdate | DATE | NO | — | Fecha de nacimiento del animal |
| weight | NUMERIC(6,2) | SÍ | — | Peso actual del animal en kg, actualizado por el último pesaje registrado |
| sex | CHAR(1) | NO | — | Sexo del animal: M (macho) o F (hembra) |
| origin | VARCHAR(300) | SÍ | — | Origen del animal (ej. "born" si nació en la estancia, "purchased" si fue comprado) |
| updated_at | TIMESTAMP | SÍ | CURRENT_TIMESTAMP | Fecha de última modificación del registro |
| created_at | TIMESTAMP | SÍ | CURRENT_TIMESTAMP | Fecha de alta del animal en el sistema |
| local_id | VARCHAR(100) | SÍ | — | Identificador generado en el dispositivo móvil para sincronización offline; único, permite idempotencia al sincronizar |

## Relaciones

| Columna | Referencia | Descripción |
|---------|------------|-------------|
| id_ranch | ranches.id_ranch | Estancia dueña del animal |
| id_breed | animal_breeds.id_breed | Raza del animal |
| id_status | animal_statuses.id_status | Estado operativo del animal: 1=Activo, 2=En Observación, 3=Inactivo, 4=Pendiente de Movimiento, 5=Vendido |
| id_mother | ranch_animals.id_ranch_animal | Animal madre (autorreferencia) |
| id_father | ranch_animals.id_ranch_animal | Animal padre (autorreferencia) |
| id_productive_status | productive_statuses.id_productive_status | Etapa productiva del animal: 1=Cría, 2=Recría, 3=Engorde, 4=Baja |
| id_animal_class | animal_classes.id_animal_class | Clasificación manual del animal (Ternera, Vaquilla, Vaca, Toro, Novillo, etc.) |
| id_lot | ranch_lots.id_lot | Lote actual del animal |

## Reglas de negocio

- RN-03: code (caravana) es único e irrepetible dentro de la estancia.
- RN-06: todo animal debe tener un id_productive_status válido en todo momento.
- RN-07: un animal en Baja (id_productive_status=4) no puede reactivarse ni recibir nuevos eventos; es una transición irreversible.
- RN-11: toda cría viva debe tener id_mother NOT NULL.
- Un animal se crea por parto (el backend lo crea automáticamente al registrar una parturition con cria_status='alive': id_mother=madre, id_productive_status=1, origin='born') o por compra (origin='purchased', id_mother/id_father pueden ser NULL).
- Transiciones de id_productive_status a lo largo del ciclo productivo: parto vivo→ps=1 (id_lot=lote de cría); destete→ps=2 (id_lot=lote de recría); ingreso a engorde→ps=3 (id_lot=lote de engorde, solo desde ps=2); venta o muerte→ps=4 con id_status=3 (Inactivo).
- id_animal_class es seleccionado manualmente por el operador al registrar el animal o al cambiar de etapa productiva; no existen campos booleanos auto-calculados de categorización (is_weaned, has_calved, is_castrated, is_sterilized fueron descartados a favor de id_animal_class).

## Notas técnicas

- sex tiene un CHECK constraint que solo admite 'M' o 'F'.
- id_mother e id_father son autorreferencias a la misma tabla (ranch_animals.id_ranch_animal).
- local_id tiene constraint UNIQUE y fue agregado mediante ALTER TABLE posterior a la creación original; soporta el patrón offline-first de idempotencia en sincronización.
- code tiene constraint UNIQUE(id_ranch, code) — no UNIQUE global. Hasta la migración `009_20260804_0000_movil_alineacion` el constraint real era global (UNIQUE(code) a secas), en contradicción con RN-05/RN-03; se corrigió para que dos estancias distintas puedan repetir un código de caravana.
