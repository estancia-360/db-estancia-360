# animal_breeds

Catálogo de razas bovinas disponibles para asignar a un animal. A diferencia de otros catálogos, es gestionado por la propia estancia, que puede agregar las razas que utilice.

## Columnas

| Columna | Tipo | Nulo | Default | Descripción |
|---------|------|------|---------|-------------|
| id_breed | SERIAL | NO | autoincremental | Identificador de la raza |
| name | VARCHAR(30) | NO | — | Nombre de la raza bovina |
| is_active | BOOLEAN | NO | TRUE | Indica si la raza está disponible para asignarse a un animal |

## Reglas de negocio

- Cada animal (`ranch_animals.id_breed`) tiene asignada una raza.
- Las razas son gestionadas por la estancia: pueden agregarse nuevas según las que use cada operación.
- `is_active` permite desactivar una raza sin eliminar el historial de animales que ya la tienen asignada.

## Notas técnicas

- El dato semilla (`data.sql`) carga 9 razas comunes en la ganadería boliviana, agrupadas por función:
  - **Carne**: Nelore, Brahman, Senepol, Sindi
  - **Leche**: Holstein, Pardo Suizo, Jersey
  - **Criollas/mestizas**: Criollo Boliviano, Mestizo
- No es una lista cerrada — la estancia puede agregar o desactivar (`is_active=FALSE`) las razas que use.
