# roles

Catálogo de roles globales del sistema, que controlan el nivel de acceso al backend de Estancia 360. Es distinto de `ranch_roles`, que son roles dentro de una estancia específica.

## Columnas

| Columna | Tipo | Nulo | Default | Descripción |
|---------|------|------|---------|-------------|
| id_role | INT | NO | — | Identificador del rol global |
| name | VARCHAR(30) | NO | — | Nombre del rol global (único) |

## Reglas de negocio

- Valores fijos: 1=Root (superadmin interno de Estancia 360), 2=Admin (administrador del sistema), 3=Usuario (ganadero, usuario final típico que se registra).
- Jerarquía de privilegios usada en los guards de autorización: ROOT(1) < ADMIN(2) < USER(3); un endpoint protegido valida `user.rol <= allowedRole`.

## Notas técnicas

- `id_role` no es `SERIAL`: los valores son fijos (1-3) y se insertan explícitamente.
- `name` tiene constraint `UNIQUE`.
