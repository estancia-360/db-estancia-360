# users

Usuarios registrados en el sistema Estancia 360. Cada usuario puede pertenecer a una o más estancias con distintos roles, a través de `ranch_users`.

## Columnas

| Columna | Tipo | Nulo | Default | Descripción |
|---------|------|------|---------|-------------|
| id_user | SERIAL | NO | autoincremental | Identificador del usuario |
| id_role | INT | NO | — | Rol global del usuario en el sistema |
| ci | VARCHAR(20) | NO | — | Cédula de identidad (identificación nacional) del usuario |
| fullname | VARCHAR(150) | NO | — | Nombre del usuario |
| paternal_surname | VARCHAR(100) | SÍ | — | Apellido paterno del usuario |
| maternal_surname | VARCHAR(100) | SÍ | — | Apellido materno del usuario |
| email | VARCHAR(150) | NO | — | Correo electrónico del usuario |
| password | VARCHAR(255) | NO | — | Contraseña del usuario, almacenada encriptada (bcrypt) |
| celphone | VARCHAR(20) | SÍ | — | Número de celular del usuario |
| is_deleted | BOOLEAN | SÍ | FALSE | Borrado lógico: indica si el usuario fue dado de baja, preservando el historial de eventos que registró |
| created_at | TIMESTAMP | SÍ | CURRENT_TIMESTAMP | Fecha de creación del registro |
| updated_at | TIMESTAMP | SÍ | CURRENT_TIMESTAMP | Fecha de última actualización del registro |

## Relaciones

| Columna | Referencia | Descripción |
|---------|------------|-------------|
| id_role | roles.id_role | Rol global del usuario en el sistema (Root, Admin o Usuario) |

## Reglas de negocio

- El rol típico de quien se registra desde la app es Usuario (id_role=3, ganadero); Admin (2) y Root (1) son roles internos de Estancia 360.
- Modo offline: el sistema soporta máximo 2 usuarios offline simultáneos por estancia — el Owner y el Administrator de esa estancia (ver `ranch_roles`) — quienes pueden registrar eventos sin conexión y sincronizarlos luego.
- El borrado de un usuario es siempre lógico (`is_deleted`), nunca físico, para preservar el historial de eventos que haya registrado.

## Notas técnicas

- A diferencia de otras tablas del sistema, usa `TIMESTAMP` (sin zona horaria) en lugar de `TIMESTAMPTZ` para `created_at`/`updated_at`.
- No existe un campo `is_active`; el estado del usuario se controla únicamente con `is_deleted`.
