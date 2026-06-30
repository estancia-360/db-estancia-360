# animal_exits

Registra la salida definitiva de un animal por muerte, descarte, pérdida u otra causa no comercial. Es conceptualmente distinta de una venta: no hay contraparte comercial, solo baja del animal del sistema productivo.

## Columnas

| Columna | Tipo | Nulo | Default | Descripción |
|---------|------|------|---------|-------------|
| id_exit | BIGSERIAL | NO | autoincremental | Identificador único de la salida. |
| id_event | BIGINT | NO | — | Evento de animal asociado a esta salida. |
| reason | VARCHAR(30) | NO | — | Causa de la salida: `death`, `discard`, `loss` u `other`. |
| notes | TEXT | SÍ | — | Detalle adicional; obligatorio en la práctica cuando `reason='other'`. |
| created_at | TIMESTAMP | NO | CURRENT_TIMESTAMP | Fecha de creación del registro. |
| updated_at | TIMESTAMP | NO | CURRENT_TIMESTAMP | Fecha de última actualización del registro. |

## Relaciones

| Columna | Referencia | Descripción |
|---------|------------|-------------|
| id_event | animal_events.id_animal_event | Evento que originó la salida del animal. |

## Reglas de negocio

- Se debe registrar siempre la causa de la salida (`reason`).
- Un animal dado de baja por esta vía no puede reactivarse (RN-02/RN-07): es irreversible.
- Al registrar una salida, el backend actualiza `ranch_animals.id_productive_status=4` (Baja) y `ranch_animals.id_status=3` (Inactivo).
- Se diferencia de `movements` tipo `sale` o `ranch_exit`: ambos también dejan ps=4, pero esos casos dejan `id_status=5` (Vendido) porque implican una contraparte comercial; `animal_exits` deja `id_status=3` (Inactivo) porque no hay venta ni traspaso, sino muerte o descarte.

## Notas técnicas

- `reason` restringido por CHECK a `'death'`, `'discard'`, `'loss'`, `'other'`.
- El `data.sql` de esta tabla está vacío porque es una tabla transaccional, sin catálogo semilla.
