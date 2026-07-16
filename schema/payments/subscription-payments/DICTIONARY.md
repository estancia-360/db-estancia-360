# subscription_payments

Historial de pagos registrados para una suscripción. Hoy siempre los carga un administrador a
mano después de recibir el comprobante (QR/transferencia) por correo — no hay pasarela de pagos
integrada todavía.

## Columnas

| Columna | Tipo | Nulo | Default | Descripción |
|---------|------|------|---------|-------------|
| id_payment | BIGSERIAL | NO | autoincremental | Identificador del pago |
| id_ranch_subscription | BIGINT | NO | — | Suscripción a la que corresponde este pago |
| amount | NUMERIC(10,2) | NO | — | Monto pagado en Bolivianos |
| payment_date | DATE | NO | — | Fecha en que se recibió el pago |
| payment_method | VARCHAR(20) | NO | — | 'qr' o 'transfer' |
| payment_source | VARCHAR(20) | NO | 'manual' | Quién generó el registro: 'manual' (admin) o 'gateway' (pasarela futura) |
| external_reference | VARCHAR(255) | SÍ | — | Referencia del comprobante hoy; ID de transacción de pasarela a futuro |
| period_extended_months | INT | NO | — | Cuántos meses se suman a `ranch_subscriptions.current_period_end` por este pago |
| registered_by | BIGINT | SÍ | — | Usuario (admin) que cargó el pago |
| notes | TEXT | SÍ | — | Observaciones adicionales |
| local_id | VARCHAR(100) | SÍ | — | Clave de idempotencia ante doble envío del cliente HTTP (único) |

## Relaciones

| Columna | Referencia | Descripción |
|---------|------------|-------------|
| id_ranch_subscription | ranch_subscriptions.id_ranch_subscription | Suscripción que este pago extiende |
| registered_by | users.id_user | Administrador que registró el pago manualmente |

## Reglas de negocio

- `period_extended_months` no se deriva rígido de `billing_cycle` (no es siempre 1 o 12) para
  poder registrar promociones sin caso especial en código — ej. "paga 3 meses, recibe 4 de
  regalo" se carga como `period_extended_months=4`.
- El pago anual ya viene descontado en el precio del plan (10 meses de precio, 12 de acceso); no
  hace falta lógica aparte, el admin simplemente carga `period_extended_months=12`.

## Notas técnicas

- `payment_source` y `external_reference` existen desde ya (aunque hoy siempre son
  'manual'/NULL respectivamente) para que una futura pasarela de pagos pueda insertar filas acá
  vía webhook sin requerir un cambio de schema.
- `local_id` protege contra doble envío (ej. doble clic en "Registrar pago" del panel admin):
  si el cliente reenvía el mismo `local_id`, el backend devuelve el pago ya existente en vez de
  crear uno nuevo y volver a extender `current_period_end`. Agregada en la migración
  `008_20260715_0000_subscription_payments_local_id`.
