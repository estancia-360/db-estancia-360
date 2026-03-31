-- ============================================================
-- TABLA: weanings
-- MÓDULO: Cría — Paso 4 (Final): Destete
-- ============================================================
--
-- DESCRIPCIÓN:
--   Registra el destete de una cría. Es el evento que finaliza el ciclo
--   de Cría y da inicio al de Recría. Es el ÚNICO mecanismo para pasar
--   un animal a estado productivo Recría (RN-08 / RF-04.12).
--
-- FLUJO EN EL MÓDULO CRÍA:
--   breeding_services → gestation_diagnoses → parturitions → weanings
--   (El destete se registra en el animal CRÍA, no en la madre)
--
-- CÓMO SE USA:
--   El usuario selecciona la cría a destetar, registra peso, edad en días
--   y el lote de recría destino. La cría DEBE tener id_productive_status=1
--   (Cría) para poder ser destetada.
--
-- REGLAS DE NEGOCIO:
--   - RN-08 / RF-04.12: Solo mediante un destete registrado un animal pasa
--     a Recría. No hay otro camino.
--   - RF-04.11: Al registrar el destete, el backend actualiza automáticamente
--     en ranch_animals de la cría: is_weaned=TRUE, id_productive_status=2
--     (Recría) y id_lot=id_lot_dest.
--   - RF-04.10: Se debe registrar fecha, peso al destete, edad en días y
--     lote destino.
--
-- LÓGICA BACKEND (al registrar un destete):
--   1. Verificar que id_cria existe y tiene id_productive_status=1 (Cría)
--   2. Verificar que id_lot_dest existe, es del tipo 'rearing' y pertenece
--      a una estancia con rubro Recría habilitado (ranch_production_types)
--   3. Crear animal_event (id_event_type=4 'weaning') con id_ranch_animal=id_cria
--   4. Crear weanings con el evento creado
--   5. Actualizar ranch_animals del animal cría:
--      - is_weaned = TRUE
--      - id_productive_status = 2 (Rearing)
--      - id_lot = id_lot_dest
--      - updated_at = NOW()
--
-- CAMPOS:
--   - id_event:      evento de destete (animal_events con id_event_type=4)
--                    IMPORTANTE: el id_ranch_animal del evento apunta a la CRÍA, no a la madre
--   - id_cria:       el animal que se desteta (redundante con el evento, para claridad)
--   - id_lot_dest:   lote de recría al que ingresa la cría después del destete
--   - weaning_weight:peso de la cría al momento del destete (indicador clave de Cría)
--   - weaning_age:   edad en días al destete (indicador de 'edad al primer destete')
-- ============================================================

CREATE TABLE weanings (
    id_weaning BIGSERIAL,
    id_event bigint NOT NULL,
    id_cria bigint NOT NULL,
    id_lot_dest bigint NOT NULL,
    weaning_weight numeric(10,2),
    weaning_age int,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_weaning),
    FOREIGN KEY (id_event) REFERENCES animal_events(id_animal_event) ON DELETE CASCADE,
    FOREIGN KEY (id_cria) REFERENCES ranch_animals(id_ranch_animal) ON DELETE CASCADE,
    FOREIGN KEY (id_lot_dest) REFERENCES ranch_lots(id_lot) ON DELETE CASCADE
);