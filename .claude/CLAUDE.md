# db-estancia-360

Base de datos PostgreSQL — generada con `create-db`.
Mi rol aquí es asistir en el diseño, organización, análisis y evolución de esta DB.

---

## Cómo funciona

### Dos capas independientes

```
schema/       → diseño actual: qué tablas existen y cómo están definidas
migrations/   → historia: qué cambió, en qué orden, ya aplicado a DBs reales
```

Editar `schema/` no afecta una DB existente. Para cambiar una DB con datos, siempre hay que crear una migración.

### Dos flujos

| Situación | Comando |
|---|---|
| DB vacía (dev, CI, nuevo entorno) | `psql -U user -d dbname -f init.sql` |
| DB existente con datos reales | `npm run migrate` |

### Scripts

| Comando | Hace | Necesita DB |
|---|---|---|
| `npm run build` | Fusiona todo `schema/` en `db-output.sql` siguiendo los `\i` recursivamente | No |
| `init.sql` | DROP de todo + carga `schema/` desde cero | Sí |
| `npm run migrate` | Aplica solo las migraciones de `migrations/` aún no registradas en `_migrations` | Sí |
| `npm run rollback [N]` | Revierte las últimas N migraciones ejecutando su `down.sql` (default: 1) | Sí |

### Estructura del schema

```
schema/
├── init.sql                  ← orden global (dependencias primero)
├── tabla-standalone/         ← tabla transversal a varios dominios
│   ├── create.sql
│   ├── data.sql
│   ├── init.sql
│   └── DICTIONARY.md
└── nombre-grupo/             ← dominio lógico (auth, orders, catalog…)
    ├── init.sql              ← orden dentro del grupo
    └── tabla/
        ├── create.sql
        ├── data.sql
        ├── triggers.sql      ← solo si aplica
        ├── init.sql
        └── DICTIONARY.md
```

El orden de dependencias es **siempre manual**. Quien referencia va después del referenciado.

---

## Comandos disponibles

- `/analyze` — análisis rápido de la DB actual (estructura, relaciones, catálogos, triggers)
- `/new-migration` — guía interactiva para crear una migración correctamente
- `/new-dictionary` — genera el `DICTIONARY.md` de una tabla a partir de su `create.sql`
- `/build` — corre `npm run build` y explica el `db-output.sql` generado
- `/backup` — crea un dump de la DB con nombre y ubicación correctos

---

## Backups

Los dumps van en `backups/` con formato: `YYYYMMDD_HHMMSS_descripcion.sql`

```bash
pg_dump -U user -d dbname -F p -f backups/$(date +%Y%m%d_%H%M%S)_descripcion.sql
```

Los archivos `.sql` dentro de `backups/` están en `.gitignore` — no se suben al repo.

---

## Learnings de este proyecto

<!-- Aquí se van agregando decisiones, patrones y convenciones específicas de esta DB -->
