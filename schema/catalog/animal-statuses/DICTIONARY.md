# animal_statuses

Catálogo del estado operativo de un animal, independiente de su estado productivo (`productive_statuses`). Un animal puede estar, por ejemplo, en Engorde (estado productivo) y En Observación (estado operativo) al mismo tiempo si tiene una cuarentena activa.

## Columnas

| Columna | Tipo | Nulo | Default | Descripción |
|---------|------|------|---------|-------------|
| id_status | SERIAL | NO | autoincremental | Identificador del estado operativo |
| name | VARCHAR(30) | NO | — | Nombre del estado operativo |
| is_active | BOOLEAN | NO | TRUE | Indica si el estado está disponible para asignarse a un animal |

## Reglas de negocio

- Valores fijos: 1=Activo (operación normal), 2=Observación (cuarentena o seguimiento especial por incidente sanitario), 3=Inactivo (baja por muerte/descarte vía animal_exits), 4=Pendiente de Movimiento (temporal durante una venta activa, `movements.status='pending'`; al confirmar pasa a 5=Vendido si es aceptada o revierte a 1=Activo si es rechazada), 5=Vendido (estado final tras venta confirmada y aceptada, junto con `id_productive_status=4` Baja).
- El estado 3 (Inactivo) corresponde a bajas por muerte/descarte/pérdida (animal_exits); el estado 5 (Vendido) es exclusivo del flujo de ventas (movements tipo `sale`). Ambos son estados terminales pero con origen y significado distintos (RN-21).
- RN-02: un animal dado de baja no puede reactivarse ni recibir nuevos eventos.

## Notas técnicas

- Aunque conceptualmente son terminales, los estados 3 y 5 no tienen una restricción de unicidad explícita en esta tabla catálogo; la irreversibilidad se aplica a nivel de lógica de negocio sobre `ranch_animals`.
