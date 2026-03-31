-- ============================================================
-- TABLA: animal_events
-- MÓDULO: Core — Tabla pivot central de TODOS los módulos
-- ============================================================
--
-- DESCRIPCIÓN:
--   Es la tabla más importante del sistema. CADA acción que le
--   ocurre a un animal genera primero un registro aquí. Luego,
--   la tabla de detalle del módulo correspondiente referencia
--   este id_animal_event.
--
--   Patrón: animal_events (cabecera) → tabla de detalle (cuerpo)
--
--   Esto garantiza:
--     • Trazabilidad cronológica completa de cada animal (RNF-02)
--     • Registro del usuario responsable en cada acción (RF-02.6)
--     • Un único punto de control para sincronización offline (RNF-01.4)
--
-- FLUJO DE NEGOCIO:
--   1. El usuario registra un evento desde la app móvil (offline)
--   2. La app crea primero el registro en animal_events
--   3. Luego crea el registro de detalle que referencia id_animal_event
--   4. is_synced = FALSE indica que está pendiente de enviar al servidor
--   5. Al sincronizar, is_synced pasa a TRUE
--
-- REGLAS DE NEGOCIO:
--   - RNF-02.1: Todo evento es inmutable una vez creado. Las correcciones
--               se realizan creando un nuevo evento, nunca editando.
--   - RN-15: Todo evento debe registrar el usuario responsable (id_user).
--   - RN-14: Todo cambio de estado productivo genera automáticamente un registro aquí.
--
-- TABLAS DE DETALLE QUE REFERENCIAN ESTA TABLA:
--   Cría:        breeding_services, gestation_diagnoses, parturitions, weanings
--   Recría:      weight_records, rearing_selections
--   Movimientos: animal_purchases, animal_sales, animal_transfers, animal_exits
--   Sanidad:     vaccinations, treatments, health_incidents
--   Engorde:     fattening_entries
--
-- TIPOS DE EVENTO (event_types.id_event_type):
--   1  = service           → breeding_services
--   2  = diagnosis         → gestation_diagnoses
--   3  = birth             → parturitions
--   4  = weaning           → weanings
--   5  = weight_record     → weight_records
--   6  = rearing_selection → rearing_selections
--   7  = purchase          → animal_purchases
--   8  = sale              → animal_sales
--   9  = transfer          → animal_transfers
--   10 = exit              → animal_exits
--   11 = vaccination       → vaccinations
--   12 = treatment         → treatments
--   13 = health_incident   → health_incidents
--   14 = fattening_entry   → fattening_entries
--
-- LÓGICA BACKEND (al crear cualquier evento el servicio debe):
--   1. Verificar que id_ranch_animal existe y pertenece a la estancia del usuario
--   2. Verificar que el animal NO está en estado productivo 'Baja' (id_productive_status=4) → RN-10
--   3. Crear el registro en animal_events
--   4. Retornar el id_animal_event para que el servicio de detalle lo use
--
-- CAMPOS:
--   - event_date: fecha real del evento en campo (puede diferir de created_at en offline)
--   - notes:      observación libre del operador de campo
--   - is_synced:  FALSE = pendiente de sincronizar; TRUE = ya en servidor central
-- ============================================================

CREATE TABLE animal_events (
    id_animal_event BIGSERIAL,
    id_user         BIGINT,
    id_ranch_animal INT,
    id_event_type   INT,
    notes           TEXT,
    is_synced       BOOLEAN   NOT NULL DEFAULT FALSE,
    event_date      TIMESTAMP NOT NULL,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_animal_event),
    FOREIGN KEY (id_ranch_animal) REFERENCES ranch_animals(id_ranch_animal),
    FOREIGN KEY (id_event_type)   REFERENCES event_types(id_event_type),
    FOREIGN KEY (id_user)         REFERENCES users(id_user)
);
