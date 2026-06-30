# ranch_roles

Catálogo de roles que puede tener un usuario dentro de una estancia específica. Es distinto de `roles`, que son los roles globales del sistema.

## Columnas

| Columna | Tipo | Nulo | Default | Descripción |
|---------|------|------|---------|-------------|
| id_role | SERIAL | NO | autoincremental | Identificador del rol dentro de la estancia |
| name | VARCHAR(100) | NO | — | Nombre del rol dentro de la estancia |
| is_active | BOOLEAN | SÍ | TRUE | Indica si el rol está disponible para asignarse |

## Reglas de negocio

- Valores fijos: 1=Dueño (Owner, solo uno por estancia, aprueba compras y ventas), 2=Trabajador (Worker, registra eventos productivos y sanitarios), 3=Administrador (Administrator, gestiona trabajadores).
- RN-01 / RN-16: solo el Dueño (ranch_role=1, Owner) puede registrar compras, ventas y salidas a otra estancia (ranch_exit).
- El modo offline del sistema soporta máximo 2 usuarios simultáneos por estancia: el Owner y el Administrator.
- Los permisos detallados de cada rol se aplican en la lógica de `ranch_users`, tabla que vincula usuario, estancia y rol.

## Notas técnicas

- Catálogo de datos fijos del sistema; no se espera que la estancia agregue nuevos roles.
