# db-estancia-360

Base de datos PostgreSQL — generada con [`@darkj/create-db`](https://www.npmjs.com/package/@darkj/create-db).

---

## Configuración inicial

```bash
npm install
cp .env.example .env   # completar con las credenciales reales
```

`.env` nunca se sube al repo (está en `.gitignore`).

---

## Comandos

| Comando | Hace | Necesita DB |
|---|---|---|
| `npm run build` | Fusiona todo `schema/` en `db-output.sql` | No |
| `npm run migrate` | Aplica migraciones pendientes a una DB existente | Sí |
| `npm run rollback` | Revierte la última migración | Sí |
| `npm run rollback 3` | Revierte las últimas 3 migraciones | Sí |

---

## Dos flujos de trabajo

**DB vacía** (desarrollo, CI, entorno nuevo):
```bash
psql -U user -d dbname -f init.sql
```

**DB existente con datos** (producción, staging):
```bash
npm run migrate
```

---

## Estructura

```
db-estancia-360/
├── init.sql              ← DROP ALL + recarga schema/ desde cero
├── schema/               ← diseño actual: tablas organizadas por dominio
│   └── init.sql          ← orden de carga (dependencias primero)
├── migrations/           ← historial de cambios incrementales
│   └── NNN_YYYYMMDD_HHMM_proposito/
│       ├── up.sql        ← cambios a aplicar
│       └── down.sql      ← cómo revertirlos
├── scripts/              ← build.ts · migrate.ts · rollback.ts
└── backups/              ← dumps de pg_dump (gitignored)
```

### Organización de schema/

```
schema/
├── init.sql                  ← orden global
├── tabla-standalone/         ← tabla transversal a varios dominios
│   ├── create.sql
│   ├── data.sql
│   └── init.sql
└── nombre-grupo/             ← dominio funcional (auth, orders, catalog…)
    ├── init.sql
    └── tabla/
        ├── create.sql
        ├── data.sql
        ├── triggers.sql      ← solo si aplica
        └── init.sql
```

> Todas las rutas dentro de los `init.sql` son absolutas desde la raíz del proyecto.
> `psql` resuelve `\i` desde su directorio de trabajo, no desde el archivo.

---

## Agregar una tabla

```bash
mkdir schema/mi-tabla
touch schema/mi-tabla/create.sql schema/mi-tabla/data.sql schema/mi-tabla/init.sql
```

`schema/mi-tabla/init.sql`:
```sql
\i schema/mi-tabla/create.sql
\i schema/mi-tabla/data.sql
```

Agregar a `schema/init.sql`:
```sql
\i schema/mi-tabla/init.sql
```

---

## Crear una migración

```bash
mkdir migrations/002_20260601_1000_descripcion
# escribir up.sql y down.sql
npm run migrate
```

> Nunca editar un `up.sql` ya aplicado. Para corregir errores, crear una nueva migración.

---

## Backup

```bash
pg_dump -U user -d dbname -F p -f backups/$(date +%Y%m%d_%H%M%S)_descripcion.sql
```
