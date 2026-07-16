# payments_subscriptions_module

Primera versión del módulo administrativo de Pagos/Suscripciones: `subscription_plans` (catálogo
de los 4 planes), `ranch_subscriptions` (1 por estancia, estado calculado por fecha, sin columna
`status`) y `subscription_payments` (historial de pagos, cargados a mano por un admin — sin
pasarela todavía, pero con `payment_source`/`external_reference` ya preparados para cuando
exista una). Backfillea las estancias existentes en plan Free.

No es una pasarela de pagos: el cobro sigue siendo manual (QR/transferencia, comprobante por
correo). Fuente del modelo comercial:
`documentos/Flujo_Caja_Estancia360_RECONSTRUIDO_sin_VALUE.xlsx`.
