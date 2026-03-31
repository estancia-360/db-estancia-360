-- ============================================================
-- TABLA: weight_records
-- MÓDULO: Recría y Engorde — Pesajes periódicos
-- ============================================================
--
-- DESCRIPCIÓN:
--   Registra los pesajes periódicos de los animales. Es compartida
--   entre los módulos Recría y Engorde. Cada registro es un punto
--   de peso en el tiempo para un animal específico.
--
-- CÓMO SE CALCULA ADG (Average Daily Gain / Ganancia Diaria de Peso):
--   ADG = (peso_actual - peso_anterior) / días_entre_pesajes
--   El backend calcula esto al momento de consulta usando los registros
--   de weight_records del animal ordenados por event_date. (RF-05.4)
--
-- INDICADORES QUE ALIMENTA:
--   - Recría: ADG, peso promedio del lote, desvío, ranking (RF-05.4)
--   - Engorde: pesajes de control y ganancia diaria (RF-06.3)
--   - Conversión alimenticia (RF-06.4):
--     Eficiencia = sum(feed_records.quantity) / sum(weight_delta) del mismo lote
--
-- REGLAS:
--   - El animal debe estar en estado productivo Recría o Engorde.
--   - id_lot debe ser el lote actual del animal al momento del pesaje.
--
-- LÓGICA BACKEND (al crear un pesaje):
--   1. Crear animal_event (id_event_type=5 'weight_record')
--   2. Crear weight_records referenciando ese evento
--   3. Actualizar ranch_animals.weight con el nuevo peso (peso actual)
--
-- CAMPOS:
--   - id_lot:         lote del animal al momento del pesaje (para calcular
--                     promedios y rankings por lote)
--   - weight:         peso en kg
--   - weight_type:    scale=pesado en balanza | estimated=estimado visualmente
--   - body_condition: condición corporal 1-5 (escala BCS ganadera)
--   - age_days:       edad del animal en días al momento del pesaje
-- ============================================================

CREATE TABLE weight_records (
    id_weight           BIGSERIAL,
    id_event            BIGINT          NOT NULL,
    id_lot              BIGINT          NOT NULL,
    weight              NUMERIC(8,2)    NOT NULL,
    weight_type         VARCHAR(20)     NOT NULL
        CHECK (weight_type IN ('scale', 'estimated')),
    body_condition      SMALLINT
        CHECK (body_condition BETWEEN 1 AND 5),
    age_days            INT,
    notes               TEXT,
    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_weight),
    FOREIGN KEY (id_event) REFERENCES animal_events(id_animal_event),
    FOREIGN KEY (id_lot)   REFERENCES ranch_lots(id_lot)
);
