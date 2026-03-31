-- ============================================================
-- TABLA: parturitions
-- MÓDULO: Cría — Paso 3: Registro de Parto
-- ============================================================
--
-- DESCRIPCIÓN:
--   Registra el parto de una vaca. Requiere un diagnóstico de gestación
--   previo con result='pregnant'. Si la cría nace viva, el backend crea
--   automáticamente un nuevo registro en ranch_animals (RF-04.7).
--
-- FLUJO EN EL MÓDULO CRÍA:
--   breeding_services → gestation_diagnoses → parturitions → weanings
--
-- CÓMO SE USA:
--   El usuario registra el parto indicando fecha, tipo de parto, estado de
--   la cría y condición de la madre. Si la cría está viva, la app debe
--   pedir datos adicionales (código de caravana, raza, sexo) para crear
--   el animal de la cría automáticamente.
--
-- REGLAS DE NEGOCIO:
--   - RF-04.5 / RN-12: No puede registrarse un parto sin un gestation_diagnosis
--     con result='pregnant' asociado al mismo animal. El backend valida que
--     id_diagnosis tenga result='pregnant' y que pertenezca a la misma vaca.
--   - RF-04.7: Si cria_status='alive', el backend DEBE crear automáticamente
--     un registro en ranch_animals para la cría con id_mother=madre del parto.
--   - RF-04.8: Al registrar el primer parto con cria_status='alive', el backend
--     actualiza has_calved=TRUE en ranch_animals de la madre.
--   - RN-11: Toda cría viva debe vincularse a la madre (id_mother en ranch_animals).
--
-- LÓGICA BACKEND (al crear un parto):
--   1. Verificar que id_diagnosis existe, tiene result='pregnant' y no tiene
--      parturition ya asociado (un diagnóstico solo genera un parto)
--   2. Crear animal_event (id_event_type=3 'birth') con el id del animal madre
--   3. Si cria_status='alive':
--      a. Crear ranch_animals para la cría (id_mother=madre, id_productive_status=1,
--         id_ranch=misma estancia, id_lot=lote de cría, code=dato del formulario)
--      b. Guardar id del nuevo animal en parturitions.id_cria
--   4. Si cria_status='dead':
--      a. Crear parturitions con id_cria=NULL
--   5. Si es el primer parto (has_calved=FALSE en la madre):
--      a. Actualizar ranch_animals: has_calved=TRUE para la madre
--   6. Crear parturitions con todos los datos
--
-- CAMPOS:
--   - id_diagnosis:     diagnóstico de gestación que habilita este parto
--   - birth_type:       normal | assisted (asistido) | cesarean (cesárea)
--   - id_cria:          FK al nuevo animal creado (NULL si la cría nació muerta)
--   - cria_weight:      peso al nacer de la cría (en gramos o kg según convenga)
--   - cria_status:      alive | dead
--   - mother_condition: condición post-parto de la madre: good | regular | bad
-- ============================================================

CREATE TABLE parturitions (
    id_parturition BIGSERIAL,
    id_event bigint NOT NULL,
    id_diagnosis bigint NOT NULL,
    birth_type varchar(20) NOT NULL CHECK (birth_type IN ('normal','assisted','cesarean')),
    id_cria BIGINT,
    cria_weight int,
    cria_status varchar(20) NOT NULL CHECK (cria_status IN ('alive','dead')),
    mother_condition varchar(20) CHECK (mother_condition IN ('good','regular','bad')),
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_parturition),
    FOREIGN KEY (id_event) REFERENCES animal_events(id_animal_event) ON DELETE CASCADE,
    FOREIGN KEY (id_diagnosis) REFERENCES gestation_diagnoses(id_diagnosis) ON DELETE CASCADE,
    FOREIGN KEY (id_cria) REFERENCES ranch_animals(id_ranch_animal) ON DELETE CASCADE
);