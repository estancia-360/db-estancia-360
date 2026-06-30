---
paths:
  - "migrations/**"
---

# Reglas para trabajar en migrations/

## Principio fundamental

`migrations/` es **append-only** e **inmutable**. Solo se agregan carpetas nuevas al final.
Nunca editar `up.sql` de una migración ya aplicada — si hay un error, crear una nueva migración que lo corrija.

## Estructura de cada migración

Cada migración es una **carpeta**, no un archivo suelto:

```
migrations/
└── NNN_YYYYMMDD_HHMM_proposito_breve/
    ├── up.sql      ← cambios a aplicar (obligatorio)
    ├── down.sql    ← cómo revertirlos (obligatorio)
    └── README.md   ← contexto y razón (solo si fue planeado o tiene contexto claro)
```

## Naming de la carpeta

```
NNN_YYYYMMDD_HHMM_proposito_breve
```

- `NNN` — número secuencial con ceros (`001`, `002`, `003`...)
- `YYYYMMDD` — fecha de creación
- `HHMM` — hora de creación
- `proposito_breve` — descripción corta en `snake_case`

Ejemplos:
- `003_20260524_1430_add_phone_to_users`
- `004_20260525_0900_create_index_orders_status`
- `005_20260526_1100_rename_column_amount_to_total`
- `006_20260527_1600_drop_deprecated_sessions`

## up.sql — los cambios

SQL que transforma la DB del estado anterior al nuevo. Es lo que `npm run migrate` ejecuta.

## down.sql — el reverso

SQL inverso al `up.sql`. Debe dejar la DB exactamente como estaba antes de aplicar esta migración.
Siempre escribirlo aunque no se planee usarlo — es la documentación del efecto contrario.

## README.md — contexto (opcional)

Solo crearlo si la migración fue **planeada** o tiene **contexto conocido** (decisión de negocio, bug fix, refactor coordinado).
Si el usuario pasa un script sin contexto, generar solo `up.sql` y `down.sql`, sin `README.md`.

Formato del README.md:
```markdown
# proposito_breve

{1-3 líneas explicando por qué se hace este cambio, no qué hace el SQL.}
```

## Checklist antes de escribir up.sql

1. ¿El cambio afecta datos existentes? → incluir `UPDATE`/backfill antes del `ALTER`
2. ¿Se agrega columna `NOT NULL`? → necesita `DEFAULT` o backfill previo
3. ¿Se elimina columna con datos? → primero migrar los datos, luego `DROP`
4. ¿Hay FK nueva? → la tabla referenciada ya debe existir
5. ¿Se crea índice en tabla grande? → considerar `CREATE INDEX CONCURRENTLY`
6. ¿El SQL es idempotente donde sea posible? → usar `IF NOT EXISTS`, `IF EXISTS`, `CREATE OR REPLACE`

## Cómo aplica npm run migrate

1. Conecta a la DB leyendo `.env`
2. Crea tabla `_migrations` si no existe
3. Lista las **carpetas** de `migrations/` en orden alfabético
4. Ejecuta `up.sql` de las carpetas no registradas en `_migrations`
5. Registra el **nombre de la carpeta** con timestamp al aplicarla
6. Cada migración se ejecuta en una transacción — si falla, hace ROLLBACK y para

## También actualizar schema/

Al crear una migración, actualizar también el `create.sql` correspondiente en `schema/` para que refleje el estado actual. `schema/` es el diseño vigente; `migrations/` es cómo llegamos ahí.

## Cómo revertir migraciones (npm run rollback)

`rollback.ts` elimina el registro de `_migrations` y luego ejecuta el `down.sql` dentro de la misma transacción — en ese orden, para que si el `down.sql` dropa la tabla `_migrations`, la transacción igual cierre limpia.

```bash
# Revertir la última migración aplicada
npm run rollback

# Revertir las últimas N migraciones (en orden inverso)
npm run rollback 3
```

Cómo funciona:
1. Verifica que la tabla `_migrations` exista — si no, no hay nada que revertir
2. Consulta `_migrations ORDER BY migration DESC` para obtener las últimas N
3. Por cada una, en transacción: `DELETE FROM _migrations` → ejecuta `down.sql` → `COMMIT`
4. Si `down.sql` falla, hace `ROLLBACK` y para

**El `down.sql` debe existir.** Si no existe, el script para sin revertir nada.

## Error común

Si `npm run migrate` dice que ya está al día pero los cambios no aparecen:
```sql
DELETE FROM _migrations WHERE migration = 'NNN_YYYYMMDD_HHMM_nombre';
```
Luego volver a correr `npm run migrate`. O crear una nueva migración con el cambio faltante.
