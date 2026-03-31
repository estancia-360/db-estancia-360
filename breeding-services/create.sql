-- ============================================================
-- TABLA: breeding_services
-- MÓDULO: Cría — Paso 1: Servicio Reproductivo
-- ============================================================
--
-- DESCRIPCIÓN:
--   Registra el servicio reproductivo dado a una vaca (hembra en etapa
--   Cría). Es el primer paso del ciclo reproductivo. Sin un servicio
--   registrado no se puede hacer diagnóstico ni registrar parto (RN-12).
--
-- FLUJO EN EL MÓDULO CRÍA:
--   breeding_services → gestation_diagnoses → parturitions → weanings
--
-- CÓMO SE USA:
--   El usuario selecciona la vaca a servir, elige el tipo de servicio
--   y fecha. El backend crea primero el animal_event (tipo 'service'),
--   luego crea este registro referenciando ese evento.
--
-- TIPOS DE SERVICIO:
--   - natural:                 monta natural, requiere id_animal_male (el toro)
--   - artificial_insemination: IA, requiere semen_breed y technician (RF-04.2)
--   - embryo_transfer:         transferencia embrionaria
--
-- REGLAS DE NEGOCIO:
--   - RN-13: Una vaca con diagnóstico 'pregnant' activo NO puede recibir un
--             nuevo servicio hasta que ese ciclo reproductivo finalice (parto o vacía).
--   - RF-04.1: El animal servido debe ser hembra (sex='F') en estado productivo
--               Cría (id_productive_status=1).
--   - RF-04.2: En IA se deben registrar semen_breed y technician.
--
-- LÓGICA BACKEND (al crear un servicio):
--   1. Verificar que el animal existe, es hembra y pertenece a la estancia
--   2. Verificar que NO tiene un gestation_diagnosis activo con result='pregnant'
--      (consulta: SELECT * FROM gestation_diagnoses WHERE id_service IN (servicios
--       del animal) AND result='pregnant' AND no tiene parturition asociado)
--   3. Crear animal_event (id_event_type=1 'service')
--   4. Crear breeding_services referenciando ese evento
--
-- CAMPOS:
--   - id_animal_male:    FK al toro utilizado (solo en servicio natural; NULL en IA)
--   - semen_breed:       raza del semen (solo en IA; NULL en natural)
--   - technician:        nombre del técnico (solo en IA)
--   - reproductive_lot:  referencia al lote reproductivo si aplica (texto libre)
-- ============================================================

CREATE TABLE breeding_services (
    id_service BIGSERIAL,
    id_event bigint NOT NULL,
    id_animal_male bigint,
    service_type varchar(30) NOT NULL CHECK (service_type IN ('natural','artificial_insemination','embryo_transfer')),
    semen_breed varchar(100),
    technician varchar(150),
    reproductive_lot varchar(100),
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_service),
    FOREIGN KEY (id_event) REFERENCES animal_events(id_animal_event) ON DELETE CASCADE,
    FOREIGN KEY (id_animal_male) REFERENCES ranch_animals(id_ranch_animal) ON DELETE CASCADE
);