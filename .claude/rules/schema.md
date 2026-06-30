---
paths:
  - "schema/**"
---

# Reglas para trabajar en schema/

## Regla fundamental de rutas en init.sql

**Todas las rutas en todos los `init.sql` deben ser absolutas desde la raíz del proyecto.**

psql resuelve los `\i` siempre desde su directorio de trabajo (CWD), no desde el directorio del archivo que se está leyendo. `build.py` también resuelve desde la raíz del proyecto (`ROOT_DIR`). Los dos se comportan igual — por eso todas las rutas deben ser desde la raíz.

```sql
-- CORRECTO — ruta desde la raíz
\i schema/auth/roles/create.sql
\i schema/auth/roles/data.sql

-- INCORRECTO — ruta relativa al archivo
\i create.sql
\i ../roles/create.sql
```

El usuario siempre debe estar parado en la raíz del proyecto al usar psql:
```
\cd /ruta/al/proyecto
\i init.sql
```

---

## Cómo agregar una tabla standalone

```bash
mkdir schema/mi-tabla
touch schema/mi-tabla/create.sql schema/mi-tabla/data.sql schema/mi-tabla/init.sql
```

- `create.sql` → `CREATE TABLE` con columnas, constraints y FKs
- `data.sql` → INSERTs de datos iniciales (roles, estados, catálogos). Si no hay, dejarlo comentado — el archivo debe existir igual
- `init.sql` → rutas completas desde la raíz del proyecto:

```sql
-- sin triggers
\i schema/mi-tabla/create.sql
\i schema/mi-tabla/data.sql

-- con triggers
\i schema/mi-tabla/create.sql
\i schema/mi-tabla/data.sql
\i schema/mi-tabla/triggers.sql
```

- Agregar `\i schema/mi-tabla/init.sql` a `schema/init.sql` en la posición correcta

## Cómo agregar un grupo

```bash
mkdir schema/mi-grupo
touch schema/mi-grupo/init.sql
```

El `init.sql` del grupo lista sus tablas con rutas completas desde la raíz: `\i schema/mi-grupo/mi-tabla/init.sql`. Agregar `\i schema/mi-grupo/init.sql` a `schema/init.sql`.

## Cuándo crear un grupo vs standalone

| Standalone | Grupo |
|---|---|
| Tabla transversal a varios dominios (`parameters`, `tags`, `files`) | 2+ tablas del mismo dominio funcional |
| Una sola tabla en ese dominio | Tablas que solo tienen sentido juntas |

## Lógica de agrupación por dominio

Agrupar por **responsabilidad funcional**, no por conveniencia técnica.

Grupos comunes:

| Grupo | Tablas típicas |
|---|---|
| `auth` | `users`, `roles`, `permissions`, `sessions` |
| `catalog` | `products`, `categories`, `brands` |
| `orders` | `orders`, `order_items`, `order_statuses` |
| `payments` | `payments`, `payment_methods`, `invoices` |
| `notifications` | `notifications`, `notification_types` |

Una tabla que tiene FK hacia tablas de **dos grupos distintos** probablemente va standalone, después de ambos grupos en `schema/init.sql`.

## Formato estándar de CREATE TABLE

Este es el formato propio del proyecto. Toda tabla nueva debe seguirlo sin excepción.

### Orden de columnas (de arriba hacia abajo)

```
1. PK          → primera columna, siempre
2. FKs         → en columnas simples, sin referenciar aún, después del PK
3. Atributos   → campos propios de la tabla en orden lógico de importancia
4. Timestamps  → created_at y updated_at al final, siempre TIMESTAMPTZ
5. Constraints → PRIMARY KEY primero, luego cada FOREIGN KEY con REFERENCES
```

### Naming

- **Tablas**: `snake_case`, **plural** — representan una colección de registros (`users`, `order_items`)
- **PK**: nombre de la tabla en singular + `_id` → `user_id`, `order_id`, `role_id`
  - Si el nombre es largo, usar una versión simplificada que mantenga el contexto
- **FK columns**: mismo formato que el PK de la tabla que referencian → `role_id`, `created_by`
- Índices: `idx_{tabla}_{columna}` (`idx_users_email`)
- Triggers: `trg_{tabla}_{descripcion}`
- Funciones de trigger: `fn_{tabla}_{descripcion}`
- Constraints únicos: `uq_{tabla}_{columna}` (`uq_users_email`)

### Ejemplo de referencia

```sql
CREATE TABLE users (
    user_id             SERIAL,
    role_id             INT             NOT NULL,                        -- rol asignado al usuario
    created_by          INT,                                             -- usuario que lo creó (NULL solo para root)
    full_name           VARCHAR(150)    NOT NULL,                        -- nombre completo del usuario
    username            VARCHAR(50)     NOT NULL UNIQUE,                 -- nombre de usuario único
    email               VARCHAR(150),                                    -- correo electrónico
    password_hash       VARCHAR(255)    NOT NULL,                        -- contraseña almacenada con hash seguro
    failed_attempts     SMALLINT        NOT NULL DEFAULT 0,              -- contador de intentos de login fallidos
    active              BOOLEAN         NOT NULL DEFAULT TRUE,           -- cuenta activa/inactiva (no se elimina)
    requires_pwd_change BOOLEAN         NOT NULL DEFAULT TRUE,           -- fuerza cambio de contraseña en primer ingreso
    locked_until        TIMESTAMPTZ,                                     -- fecha y hora hasta cuando la cuenta está bloqueada
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id),
    FOREIGN KEY (role_id)    REFERENCES roles(role_id),
    FOREIGN KEY (created_by) REFERENCES users(user_id)
);
```

### Reglas del formato

- **PK se declara como columna simple** (`SERIAL`) sin `PRIMARY KEY` inline — la constraint va al final
- **FKs se declaran como columnas simples** (`INT`, `INT NOT NULL`) sin `REFERENCES` inline — la constraint va al final
- **Alineación visual**: columna, tipo, constraints y comentario alineados con espacios para legibilidad
- **Comentarios inline** (`--`) en toda columna que no sea autoexplicativa por su nombre
- **`NOT NULL` explícito** en toda columna que no admite nulos — nunca asumir por defecto
- **Timestamps**: siempre `TIMESTAMPTZ` (con zona horaria), nunca `TIMESTAMP` a secas
- **Orden de constraints al final**: primero `PRIMARY KEY`, luego `FOREIGN KEY` en el mismo orden que aparecen las columnas FK arriba

### Tipos de datos

| Dato | Tipo |
|---|---|
| PK autoincremental | `SERIAL` |
| FK, referencia a otra tabla | `INT` |
| Texto con longitud conocida | `VARCHAR(N)` |
| Texto sin límite | `TEXT` |
| Contador pequeño | `SMALLINT` |
| Número entero general | `INT` |
| Dinero / precisión decimal | `NUMERIC(10,2)` — nunca `FLOAT` |
| Booleano | `BOOLEAN` — nunca `INT` ni `CHAR` |
| Solo fecha | `DATE` |
| Fecha + hora + zona | `TIMESTAMPTZ` — siempre esta, nunca `TIMESTAMP` a secas |
| Enumeraciones | tabla de catálogo con FK — nunca `ENUM` de Postgres (difícil de migrar) |

### Columnas de auditoría

Toda tabla de datos (no catálogo puro) cierra con:
```sql
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
```

El `updated_at` se mantiene con un trigger en `triggers.sql`.
Si aplica borrado lógico, agregar `deleted_at TIMESTAMPTZ` antes de `created_at`.

### Integridad referencial

Elegir `ON DELETE` conscientemente en cada FK:

- `CASCADE` → el hijo no tiene sentido sin el padre (`order_items` → `orders`)
- `SET NULL` → la relación es opcional (la columna FK debe admitir NULL)
- Sin cláusula (default `RESTRICT`) → el borrado del padre se bloquea explícitamente

### Índices

- La PK ya crea índice automáticamente
- Crear índices en columnas frecuentes en `WHERE`, `JOIN ON`, `ORDER BY`
- Índice compuesto cuando las queries filtran por dos columnas juntas
- No sobre-indexar: cada índice tiene costo en escritura

### Triggers

Solo crear `triggers.sql` si la tabla realmente lo necesita.
Siempre usar `CREATE OR REPLACE FUNCTION` para que sea re-ejecutable.

---

## Diccionario de tabla (DICTIONARY.md)

Cada carpeta de tabla debe tener un `DICTIONARY.md` junto a `create.sql`, `data.sql` e `init.sql`.

**Cuándo generarlo**: al crear una tabla nueva o al recibir un `create.sql` existente.
Si trabajo en una tabla que no tiene su `DICTIONARY.md`, preguntar si debo generarlo.

### Plantilla

```markdown
# {nombre_tabla}

{Descripción en 1-2 líneas: qué representa esta tabla en el dominio del negocio.}

## Columnas

| Columna | Tipo | Nulo | Default | Descripción |
|---------|------|------|---------|-------------|
| {col}   | {tipo} | NO/SÍ | {default o —} | {descripción en lenguaje de negocio} |

## Relaciones

| Columna | Referencia | Descripción |
|---------|------------|-------------|
| {fk_col} | {tabla.col} | {qué representa esta relación en el negocio} |

## Reglas de negocio

- {regla o restricción relevante para el negocio}
- {caso especial o comportamiento esperado}

## Notas técnicas

- {constraints, triggers, índices relevantes que no son obvios del create.sql}
```

### Reglas del diccionario

- La descripción del header explica **qué representa** la tabla, no cómo está implementada
- Columnas: descripciones en **lenguaje de negocio**, no técnico ("Rol del usuario" no "FK a roles")
- Relaciones: solo las FK; explicar el **significado de la relación**, no solo el dato técnico
- Reglas de negocio: comportamiento esperado, casos borde, qué operaciones están prohibidas
- Notas técnicas: solo lo que no es visible a simple vista en el `create.sql` (triggers, índices, constraints nombrados)
- Si una sección no aplica (ej. tabla sin FK → sin sección Relaciones), omitirla completamente
