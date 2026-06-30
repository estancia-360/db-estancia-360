# productive_statuses

Catálogo de las etapas del ciclo de vida productivo de un bovino. El backend actualiza `ranch_animals.id_productive_status` automáticamente en cada transición del ciclo productivo.

## Columnas

| Columna | Tipo | Nulo | Default | Descripción |
|---------|------|------|---------|-------------|
| id_productive_status | INT | NO | — | Identificador de la etapa productiva |
| name | VARCHAR(50) | NO | — | Nombre de la etapa productiva |
| is_active | BOOLEAN | NO | TRUE | Indica si la etapa está disponible para asignarse a un animal |

## Reglas de negocio

- Flujo de transición: 1=Cría → estado inicial de todo animal nacido o comprado. 2=Recría → se asigna automáticamente al destetar (weanings). 3=Engorde → se asigna al ingresar a engorde (fattening_entries). 4=Baja → se asigna al vender (sale aceptada / ranch_exit) o al registrar muerte/descarte (animal_exits).
- RN-07: el estado 4 (Baja) es irreversible — aplica a venta aceptada, salida a otra estancia (ranch_exit) y baja por muerte/descarte (animal_exit).
- RN-09: el ingreso a Engorde (ps=3) solo es válido desde Recría (ps=2) y si la estancia tiene el rubro Engorde habilitado.
- RN-06: todo animal debe tener un `id_productive_status` válido en todo momento.

## Notas técnicas

- A diferencia de otros catálogos, `id_productive_status` no es `SERIAL`: los valores son fijos y se insertan explícitamente (1-4).
