# subscription_payments_local_id

`POST /admin/subscriptions/:idRanch/payments` no tenía protección contra doble envío: un doble
clic del admin en el panel (cuando exista, todavía es Fase 2) crea dos registros de pago y
extiende `current_period_end` el doble sin que nadie lo note — a diferencia del resto de los
endpoints de creación del proyecto, que ya usan `local_id` para esto. Se agrega la misma columna
a `subscription_payments` para dar idempotencia ante reintentos/doble clic, aunque este módulo no
tenga sync offline.
