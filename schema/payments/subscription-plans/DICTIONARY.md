# subscription_plans

Catálogo de planes comerciales de Estancia360 (Free, Estancia, Hacienda, Ganadero Plus). Define
la capacidad de animales y el precio de cada plan; todos los planes tienen la misma
funcionalidad en el MVP.

## Columnas

| Columna | Tipo | Nulo | Default | Descripción |
|---------|------|------|---------|-------------|
| id_plan | SERIAL | NO | autoincremental | Identificador del plan |
| name | VARCHAR(30) | NO | — | Nombre comercial del plan |
| capacity_min | INT | NO | — | Cantidad mínima de animales que cubre el plan |
| capacity_max | INT | SÍ | — | Cantidad máxima de animales; NULL = sin límite |
| price_monthly | NUMERIC(8,2) | NO | — | Precio mensual en Bolivianos |
| price_annual | NUMERIC(8,2) | NO | — | Precio anual en Bolivianos (ya con descuento: paga 10 meses, usa 12) |
| trial_days | INT | NO | 0 | Días de prueba gratuita al activar el plan por primera vez (0 en Free) |
| is_active | BOOLEAN | NO | TRUE | Si el plan sigue disponible para asignarse a nuevas estancias |

## Reglas de negocio

- El límite de capacidad de animales es la única diferencia funcional real entre planes en el MVP.
- Free (0-30 animales) no es una prueba con vencimiento — es un plan permanente sin costo.
- `is_active=FALSE` permite retirar un plan de venta sin romper el historial de estancias que ya lo tienen asignado.
- Precio anual efectivo mensual siempre es menor al mensual puro (incentivo a pagar por adelantado).

## Notas técnicas

- Seed inicial (`data.sql`) carga los 4 planes vigentes según `documentos/Flujo_Caja_Estancia360_RECONSTRUIDO_sin_VALUE.xlsx`.
