# movil_alineacion

Parte de un reajuste grande de la app móvil para alinearla con el backend real (sync de
Movimientos roto, seguridad, etc.). Agrega `local_id` a las 4 tablas que quedaron sin
idempotencia offline (vaccinations, treatments, health_incidents, fattening_entries) y corrige
`ranch_animals.code` de único-global a único-por-estancia, que es lo que RN-05 documentó desde
siempre pero el constraint real nunca implementó.
