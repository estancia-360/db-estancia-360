# weight_columns_precision

Unificar todas las columnas de peso del sistema al mismo rango: máximo 4 dígitos enteros + 2 decimales (hasta 9999.99 kg). `parturitions.cria_weight` ya estaba en NUMERIC(6,2) desde la migración `002_20260613_0000_parturitions_cria_weight_numeric`.
