-- ============================================================
-- TABLA: rearing_selections
-- MÓDULO: Recría — Selección para Reposición o Engorde
-- ============================================================
--
-- DESCRIPCIÓN:
--   Registra la decisión de destino de un animal al finalizar la etapa
--   de Recría. Es el evento que determina si el animal va a reposición
--   (queda en la estancia como reproductor), a engorde (ciclo de
--   terminación) o a venta directa.
--
-- DESTINOS POSIBLES:
--   - replacement: el animal es seleccionado como futuro reproductor.
--                  Permanece en la estancia, su estado productivo permanece
--                  en Recría hasta ingresar a ciclo reproductivo.
--   - fattening:   el animal pasa a Engorde. El backend debe crear
--                  adicionalmente un fattening_entry (RF-05.6 / RN-09).
--                  Requiere que la estancia tenga rubro Engorde habilitado.
--   - sale:        el animal se vende directamente desde Recría.
--                  El backend debe crear un animal_sale (Movimientos).
--
-- REGLAS DE NEGOCIO:
--   - RF-05.5: Se evalúa peso, condición corporal y score genético.
--   - RN-09: Un animal pasa a Engorde solo si está en Recría y la estancia
--            tiene el rubro Engorde habilitado (ranch_production_types).
--
-- LÓGICA BACKEND (al crear una selección):
--   1. Verificar que el animal está en id_productive_status=2 (Recría)
--   2. Crear animal_event (id_event_type=6 'rearing_selection')
--   3. Crear rearing_selections
--   4. Si destination='fattening':
--      a. Crear animal_event (id_event_type=14 'fattening_entry')
--      b. Crear fattening_entries
--      c. Actualizar ranch_animals: id_productive_status=3, id_lot=id_lot_dest
--   5. Si destination='sale':
--      a. Crear animal_event (id_event_type=8 'sale')
--      b. Crear animal_sales
--      c. Actualizar ranch_animals: id_productive_status=4, id_status=3
--
-- CAMPOS:
--   - id_lot_dest:         lote destino (aplica si destination='fattening' o 'replacement')
--   - weight_at_selection: peso al momento de la selección
--   - body_condition:      condición corporal 1-5
--   - genetic_score:       puntaje genético (evaluación del criador)
--   - age_days:            edad del animal en días al seleccionar
-- ============================================================

CREATE TABLE rearing_selections (
    id_selection        BIGSERIAL,
    id_event            BIGINT          NOT NULL,
    id_lot_dest         BIGINT,
    destination         VARCHAR(20)     NOT NULL
        CHECK (destination IN ('replacement', 'fattening', 'sale')),
    weight_at_selection NUMERIC(8,2),
    body_condition      SMALLINT
        CHECK (body_condition BETWEEN 1 AND 5),
    genetic_score       NUMERIC(5,2),
    age_days            INT,
    notes               TEXT,
    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_selection),
    FOREIGN KEY (id_event)    REFERENCES animal_events(id_animal_event),
    FOREIGN KEY (id_lot_dest) REFERENCES ranch_lots(id_lot)
);
