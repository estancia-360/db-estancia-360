Genera el archivo DICTIONARY.md para una tabla de este proyecto.

Si el usuario no especificó qué tabla, preguntá cuál.

Luego:
1. Leé el `create.sql` de esa tabla para obtener columnas, tipos, constraints y FKs
2. Leé el `data.sql` para entender qué datos iniciales maneja (útil para las reglas de negocio)
3. Si existe `triggers.sql`, leélo para documentarlo en Notas técnicas

Generá el `DICTIONARY.md` siguiendo exactamente esta plantilla:

---

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

## Notas técnicas

- {constraints, triggers, índices relevantes que no son obvios del create.sql}

---

Reglas al generar:
- Descripciones siempre en lenguaje de negocio, no técnico
- Si una sección no aplica (sin FKs, sin reglas especiales), omitirla completamente
- El orden de filas en Columnas debe seguir el mismo orden que en el create.sql
- Guardarlo en: schema/{grupo-si-aplica}/{tabla}/DICTIONARY.md
