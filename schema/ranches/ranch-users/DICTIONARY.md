# ranch_users

Relación entre usuarios del sistema y estancias, definiendo el rol que cada usuario tiene dentro de cada estancia.

## Columnas

| Columna | Tipo | Nulo | Default | Descripción |
|---------|------|------|---------|-------------|
| id_user | INT | NO | — | Usuario asignado a la estancia |
| id_ranch | INT | NO | — | Estancia a la que pertenece el usuario |
| id_role | INT | NO | — | Rol del usuario dentro de la estancia (Owner, Worker o Administrator) |
| is_deleted | BOOLEAN | SÍ | false | Borrado lógico: indica si la asignación fue dada de baja sin eliminar el registro, por trazabilidad |
| created_at | TIMESTAMP | SÍ | current_timestamp | Fecha en que el usuario fue vinculado a la estancia |
| updated_at | TIMESTAMP | SÍ | current_timestamp | Fecha de última modificación del registro |

## Relaciones

| Columna | Referencia | Descripción |
|---------|------------|-------------|
| id_user | users.id_user | Usuario del sistema vinculado a la estancia |
| id_ranch | ranches.id_ranch | Estancia en la que el usuario tiene un rol |
| id_role | ranch_roles.id_ranch_role | Rol del usuario dentro de esa estancia específica |

## Reglas de negocio

- Cada estancia tiene un único Owner (id_role=1).
- Solo el Owner puede crear o eliminar Administradores (id_role=3).
- Owner: único por estancia, aprueba movimientos externos (compras y ventas).
- Worker (id_role=2): puede registrar eventos productivos y sanitarios, pero no puede crear usuarios ni aprobar movimientos externos.
- Administrator (id_role=3): puede registrar y gestionar trabajadores, pero no puede crear ni eliminar otros Administradores.
- Los usuarios solo pueden operar dentro de la estancia a la que están asignados.
- El sistema soporta un máximo de 2 usuarios offline por estancia: el Owner y el Administrator.

## Notas técnicas

- Clave primaria compuesta (id_user, id_ranch): un mismo usuario puede estar vinculado a varias estancias, con un único rol por estancia.
- is_deleted implementa borrado lógico para mantener trazabilidad histórica de quién perteneció a la estancia.
