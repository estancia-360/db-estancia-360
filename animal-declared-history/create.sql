-- ============================================================
-- TABLA: animal_declared_history
-- MÓDULO: Cría — Historial Productivo Previo Declarado
-- ============================================================
--
-- DESCRIPCIÓN:
--   Permite registrar el historial productivo de animales que ingresan
--   al sistema cuando ya tienen historia previa (pre-digitalización).
--   Es de carácter REFERENCIAL, no se usa para calcular indicadores
--   actuales del sistema (RF-03.10).
--
-- CUÁNDO SE USA:
--   Al registrar una vaca comprada o al inicializar el sistema en una
--   estancia existente. El operador declara cuántos partos tuvo la vaca
--   antes de entrar al sistema, el año del último parto, y el promedio
--   de peso al destete histórico.
--
-- IMPORTANTE:
--   - Un animal puede tener 0 o 1 registros en esta tabla.
--   - No genera animal_event (no es un evento del ciclo productivo).
--   - Los indicadores del módulo Cría (tasa de preñez, etc.) se calculan
--     solo sobre los eventos registrados en el sistema, no sobre este
--     historial declarado.
--
-- CAMPOS:
--   - prev_births_count:      cantidad de partos antes de entrar al sistema
--   - prev_last_birth_year:   año del último parto previo
--   - prev_avg_weaning_weight:peso promedio al destete de crías anteriores (kg)
--   - notes:                  observaciones adicionales del operador
-- ============================================================

CREATE TABLE animal_declared_history (
    id_history BIGSERIAL,
    id_ranch_animal BIGINT NOT NULL,
    prev_births_count INT,
    prev_last_birth_year INT,
    prev_avg_weaning_weight DECIMAL(10, 2),
    notes TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_history),
    FOREIGN KEY (id_ranch_animal) REFERENCES ranch_animals(id_ranch_animal)
);