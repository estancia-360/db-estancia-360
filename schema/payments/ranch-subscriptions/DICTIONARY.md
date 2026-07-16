# ranch_subscriptions

Suscripción vigente de una estancia — una fila por estancia (1:1), con el plan actual y las
fechas que determinan si está al día. Se crea automáticamente en plan Free al registrar la
estancia.

## Columnas

| Columna | Tipo | Nulo | Default | Descripción |
|---------|------|------|---------|-------------|
| id_ranch_subscription | BIGSERIAL | NO | autoincremental | Identificador de la suscripción |
| id_ranch | BIGINT | NO | — | Estancia dueña de esta suscripción (única por estancia) |
| id_plan | INT | NO | — | Plan actualmente asignado |
| billing_cycle | VARCHAR(10) | SÍ | — | 'monthly' o 'annual'; NULL en Free (no factura) |
| trial_ends_at | DATE | SÍ | — | Fin del período de prueba gratuita del plan pago actual; NULL en Free |
| current_period_end | DATE | SÍ | — | Fecha hasta la que está pago el plan; NULL en Free |
| cancelled_at | DATE | SÍ | — | Fecha en que un admin canceló la suscripción a mano |

## Relaciones

| Columna | Referencia | Descripción |
|---------|------------|-------------|
| id_ranch | ranches.id_ranch | Estancia a la que pertenece esta suscripción |
| id_plan | subscription_plans.id_plan | Plan comercial actualmente asignado |

## Reglas de negocio

- El estado efectivo (trial/active/expired/cancelled) **no se guarda** — se calcula en el backend
  a partir de `cancelled_at`, `trial_ends_at` y `current_period_end` comparados contra la fecha
  actual. Evita depender de un proceso programado que actualice un campo de estado.
- Si el estado calculado es `expired`, la estancia vuelve al límite de capacidad de animales del
  plan Free (30) para registrar animales nuevos — los animales ya existentes no se ven afectados.
- Cada pago registrado en `subscription_payments` extiende `current_period_end`.

## Notas técnicas

- `UNIQUE (id_ranch)` — garantiza una sola suscripción activa por estancia; no se guarda
  historial de suscripciones viejas acá, eso vive implícitamente en `subscription_payments`.
