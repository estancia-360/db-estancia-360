-- ============================================================
-- TABLA: vaccinations
-- MÓDULO: Sanidad — Vacunaciones
-- ============================================================
--
-- DESCRIPCIÓN:
--   Registra las vacunas aplicadas a un animal. Aplica en cualquier
--   etapa productiva (Cría, Recría, Engorde). Incluye también la
--   aplicación de antiparasitarios sin período de retiro.
--
-- REGLAS DE NEGOCIO:
--   - RF-07.1: Registrar vacuna, dosis y responsable (mínimo).
--   - RN-17: Todo registro sanitario debe asociarse a un animal específico.
--   - Para antiparasitarios CON período de retiro usar treatments (no esta tabla).
--
-- LÓGICA BACKEND (al registrar una vacunación):
--   1. Crear animal_event (id_event_type=11 'vaccination')
--   2. Crear vaccinations referenciando ese evento
--
-- CAMPOS:
--   - vaccine_name: nombre de la vacuna o antiparasitario (texto libre)
--   - dose:         dosis aplicada (ej: '5ml', '2cc')
--   - responsible:  nombre del responsable o veterinario
--   - notes:        observaciones adicionales
-- ============================================================

CREATE TABLE vaccinations (
    id_vaccination      BIGSERIAL,
    id_event            BIGINT          NOT NULL,
    vaccine_name        VARCHAR(150)    NOT NULL,
    dose                VARCHAR(50),
    responsible         VARCHAR(150),
    notes               TEXT,
    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_vaccination),
    FOREIGN KEY (id_event) REFERENCES animal_events(id_animal_event)
);
