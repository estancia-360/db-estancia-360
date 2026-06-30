-- ============================================================
-- TABLA: health_incidents
-- MÓDULO: Sanidad — Eventos Sanitarios
-- ============================================================
--
-- DESCRIPCIÓN:
--   Registra eventos sanitarios que no son vacunaciones ni tratamientos
--   directos. Incluye la detección de enfermedades y la declaración
--   de cuarentena. La mortalidad se registra en animal_exits (Movimientos).
--
-- TIPOS DE INCIDENTE:
--   - illness_detected: se detectó una enfermedad o síntoma en el animal.
--                       Puede acompañarse de un treatment posterior.
--   - quarantine:       el animal fue separado del resto del lote por riesgo
--                       sanitario. El backend debe actualizar id_status=2
--                       (En Observación) en ranch_animals.
--
-- REGLAS DE NEGOCIO:
--   - RF-07.3: El sistema registra enfermedades detectadas y cuarentenas.
--   - RN-17: Todo incidente asociado a un animal específico.
--
-- LÓGICA BACKEND (al registrar un incidente):
--   1. Crear animal_event (id_event_type=13 'health_incident')
--   2. Crear health_incidents
--   3. Si incident_type='quarantine': actualizar ranch_animals.id_status=2
--   4. Al marcar resolved_at: si el animal estaba en cuarentena,
--      volver ranch_animals.id_status=1 (Activo)
--
-- CAMPOS:
--   - incident_type: illness_detected | quarantine
--   - description:   descripción del incidente (síntomas, observaciones)
--   - resolved_at:   fecha en que se resolvió el incidente (NULL = aún activo)
--   - notes:         notas adicionales del responsable
-- ============================================================

CREATE TABLE health_incidents (
    id_incident         BIGSERIAL,
    id_event            BIGINT          NOT NULL,
    incident_type       VARCHAR(30)     NOT NULL
        CHECK (incident_type IN (
            'illness_detected',
            'quarantine'
        )),
    description         VARCHAR(300),
    resolved_at         DATE,
    notes               TEXT,
    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_incident),
    FOREIGN KEY (id_event) REFERENCES animal_events(id_animal_event)
);
