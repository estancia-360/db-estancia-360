Creá una nueva migración para este proyecto siguiendo el formato de carpetas.

## Paso 1 — Determinar el número siguiente

Listá las carpetas en `migrations/` en orden alfabético.
El próximo número es el último + 1, con ceros a la izquierda (ej: si existe `004_...`, el siguiente es `005`).

## Paso 2 — Obtener información

Si el usuario no la dio, preguntá:
- ¿Qué cambio se quiere hacer?
- ¿Hay contexto o razón detrás del cambio? (para decidir si crear README.md)

Si el usuario pasó un script SQL directamente, usarlo como base para `up.sql` — ordenarlo y limpiarlo si hace falta.

## Paso 3 — Crear la carpeta

Nombre: `NNN_YYYYMMDD_HHMM_proposito_breve`
- Fecha y hora actuales
- Propósito en snake_case, breve (3-5 palabras máximo)

```
migrations/NNN_YYYYMMDD_HHMM_proposito_breve/
├── up.sql
├── down.sql
└── README.md   ← solo si hay contexto claro
```

## Paso 4 — Escribir up.sql

Aplicar el checklist:
- ¿Columna NOT NULL nueva? → necesita DEFAULT o backfill previo
- ¿Eliminás columna con datos? → primero migrar datos, luego DROP
- ¿FK nueva? → la tabla referenciada ya debe existir
- ¿Índice en tabla grande? → sugerir CONCURRENTLY

## Paso 5 — Escribir down.sql

SQL inverso al up.sql. Debe dejar la DB en el estado anterior exactamente.
Siempre escribirlo, aunque el usuario no lo haya pedido.

## Paso 6 — Crear README.md (solo si hay contexto)

Si la migración fue planeada o el usuario explicó la razón:
```markdown
# proposito_breve

{1-3 líneas del por qué, no del qué.}
```

Si el usuario pasó el script sin contexto: no crear README.md.

## Paso 7 — Actualizar schema/

Identificá qué archivos `create.sql` en `schema/` quedan desactualizados y actualizalos para reflejar el nuevo estado de las tablas afectadas.

## Paso 8 — Mostrar el comando para aplicar

```bash
npm run migrate
```
