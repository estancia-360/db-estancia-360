# animal_classes

Catálogo de las categorías (clases) de bovinos que maneja el sistema, según la clasificación estándar del Anexo 1 del documento de diseño. La categoría de cada animal es seleccionada manualmente por el operador al registrarlo o al cambiar de etapa productiva; no se calcula automáticamente.

## Columnas

| Columna | Tipo | Nulo | Default | Descripción |
|---------|------|------|---------|-------------|
| id_animal_class | INT | NO | — | Identificador de la categoría bovina |
| name | VARCHAR(100) | NO | — | Nombre de la categoría |
| sex | CHAR(1) | NO | — | Sexo al que aplica la categoría: F=Hembra, M=Macho |
| is_active | BOOLEAN | NO | TRUE | Indica si la categoría está disponible para asignarse a un animal |

## Reglas de negocio

- `id_animal_class` es seleccionado manualmente por el operador en `ranch_animals.id_animal_class`; reemplaza el enfoque original de campos booleanos auto-calculados (`is_weaned`, `has_calved`, `is_castrated`, `is_sterilized`), que fueron descartados por decisión del equipo.
- `sex` permite filtrar las opciones del formulario de registro según el sexo del animal que se está dando de alta.
- Categorías por grupo etario:
  - Terneros (no destetados, menores de 11 meses): 1=Ternera (F), 2=Ternero Macho Entero (M), 3=Ternero Macho Castrado (M).
  - Destetados (post-destete, hasta el año de edad): 4=Hembra Destetada (F), 5=Macho Entero Destetado (M), 6=Macho Castrado Destetado (M).
  - Adultos (12 meses o más): 7=Vaquilla (F), 8=Vaca (F), 9=Hembra Esterilizada (F), 10=Torillo (M), 11=Novillo (M).
- `is_active` permite deshabilitar categorías sin eliminar registros históricos de animales que ya la usan.

## Notas técnicas

- `sex` tiene un `CHECK` que solo admite los valores `'M'` o `'F'`.
- `id_animal_class` no es `SERIAL`: los valores son fijos (1-11) y se insertan explícitamente.
