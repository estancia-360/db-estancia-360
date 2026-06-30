# movimientos_module

El módulo de movimientos fue rediseñado según el documento "MÓDULO MOVIMIENTOS_COMPLETO" (2026-05-23). El modelo event-first anterior (animal_transfers, animal_sales, animal_purchases) no soportaba operaciones batch por lote, el proceso de venta en dos fases (registrar → confirmar/rechazar por animal) ni la cancelación con rollback de estado.

Se reemplazan por `movements` (operación madre) + `movement_animals` (detalle por animal, con snapshot para rollback), y se agregan los estados 4 "Pendiente de Movimiento" y 5 "Vendido" a `animal_statuses`.
