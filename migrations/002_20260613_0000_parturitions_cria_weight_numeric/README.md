# parturitions_cria_weight_numeric

La columna `cria_weight` era INT, pero el DTO de registro de parto (`RegisterParturitionDto.criaWeight`) acepta hasta 2 decimales, igual que el resto de los campos de peso del sistema (`ranch_animals.weight`, `weight_records.weight`). Enviar un peso decimal (ej. 35.5) producía un error 500 de Postgres.
