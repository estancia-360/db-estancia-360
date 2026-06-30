-- ============================================================
-- TABLA: treatments
-- MÓDULO: Sanidad — Tratamientos Médicos
-- ============================================================
--
-- DESCRIPCIÓN:
--   Registra tratamientos médicos aplicados a un animal (medicamentos,
--   antibióticos, antiparasitarios con retiro). El período de retiro
--   (withdrawal) es clave: un animal bajo retiro activo NO puede venderse
--   (RN-18 / RF-06.6).
--
-- PERÍODO DE RETIRO:
--   withdrawal_days: días de retiro sanitario del medicamento.
--   withdrawal_end_date: fecha calculada de fin del retiro.
--     Cálculo: withdrawal_end_date = event_date + withdrawal_days días.
--   El backend calcula withdrawal_end_date automáticamente.
--   Al intentar registrar una venta, el backend verifica:
--     SELECT * FROM treatments WHERE id_animal = X AND withdrawal_end_date >= NOW()
--     Si hay resultado → bloquear la venta.
--
-- REGLAS DE NEGOCIO:
--   - RF-07.2: Registrar enfermedad, medicamento, dosis, duración y responsable.
--   - RF-07.5: El sistema debe registrar y respetar el período de retiro.
--   - RN-17: Todo tratamiento asociado a un animal específico.
--   - RN-18: Bloquear venta si withdrawal_end_date >= fecha actual.
--
-- LÓGICA BACKEND (al registrar un tratamiento):
--   1. Crear animal_event (id_event_type=12 'treatment')
--   2. Calcular withdrawal_end_date = event_date + withdrawal_days (si aplica)
--   3. Crear treatments
--
-- CAMPOS:
--   - illness:            enfermedad o diagnóstico (texto libre)
--   - medication:         medicamento aplicado (obligatorio)
--   - dose:               dosis aplicada
--   - duration_days:      duración total del tratamiento en días
--   - withdrawal_days:    días de retiro del medicamento (0 o NULL = sin retiro)
--   - withdrawal_end_date:fecha fin del retiro (calculada automáticamente)
--   - responsible:        veterinario o responsable
-- ============================================================

CREATE TABLE treatments (
    id_treatment        BIGSERIAL,
    id_event            BIGINT          NOT NULL,
    illness             VARCHAR(150),
    medication          VARCHAR(150)    NOT NULL,
    dose                VARCHAR(50),
    duration_days       INT,
    withdrawal_days     INT,
    withdrawal_end_date DATE,
    responsible         VARCHAR(150),
    notes               TEXT,
    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_treatment),
    FOREIGN KEY (id_event) REFERENCES animal_events(id_animal_event)
);
