-- ============================================================
-- TABLA: gestation_diagnoses
-- MÓDULO: Cría — Paso 2: Diagnóstico de Gestación
-- ============================================================
--
-- DESCRIPCIÓN:
--   Registra el diagnóstico de gestación de una vaca después de un
--   servicio. Siempre referencia un breeding_service previo (RF-04.5).
--   Este diagnóstico es el que habilita el registro de un parto.
--
-- FLUJO EN EL MÓDULO CRÍA:
--   breeding_services → gestation_diagnoses → parturitions → weanings
--
-- CÓMO SE USA:
--   El veterinario o responsable diagnóstica si la vaca quedó preñada.
--   Se crea un animal_event (tipo 'diagnosis') y luego este registro.
--
-- RESULTADOS POSIBLES:
--   - pregnant: la vaca está gestante → activa la posibilidad de registrar parto
--   - empty:    la vaca resultó vacía → se puede intentar nuevo servicio
--
-- REGLAS DE NEGOCIO:
--   - RF-04.5 / RN-12: No puede registrarse un parto (parturitions) sin que
--     exista un gestation_diagnosis con result='pregnant' asociado.
--   - RF-04.4: Se debe registrar método, resultado, días estimados de gestación,
--     fecha estimada de parto y nombre del veterinario.
--   - Una vaca puede tener múltiples diagnósticos en su vida (uno por ciclo).
--     Solo el más reciente con result='pregnant' sin parto asociado es "activo".
--
-- LÓGICA BACKEND (al crear un diagnóstico):
--   1. Verificar que el id_service existe y pertenece al mismo animal
--   2. Crear animal_event (id_event_type=2 'diagnosis')
--   3. Crear gestation_diagnoses con id_service
--   4. Si result='pregnant': marcar ciclo como activo (no hay acción directa en DB,
--      se consulta dinámicamente en la validación del servicio nuevo - RN-13)
--   5. Si result='empty': el animal puede recibir nuevo servicio
--
-- CAMPOS:
--   - id_service:      servicio del que deriva este diagnóstico (obligatorio)
--   - method:          palpation (palpación rectal) | ultrasound (ecografía)
--   - result:          pregnant | empty
--   - gestation_days:  días estimados de gestación al momento del diagnóstico
--   - estimated_birth: fecha estimada de parto (calculada por el vet)
--   - veterinarian:    nombre del veterinario responsable (texto libre)
-- ============================================================

CREATE TABLE gestation_diagnoses (
    id_diagnosis SERIAL,
    id_event bigint NOT NULL,
    id_service bigint NOT NULL,
    method varchar(20) NOT NULL CHECK (method IN ('palpation','ultrasound')),
    result varchar(20) NOT NULL CHECK (result IN ('pregnant','empty')),
    gestation_days int,
    estimated_birth date,
    veterinarian varchar(150),
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_diagnosis),
    FOREIGN KEY (id_event) REFERENCES animal_events(id_animal_event) ON DELETE CASCADE,
    FOREIGN KEY (id_service) REFERENCES breeding_services(id_service) ON DELETE CASCADE
);