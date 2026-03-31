-- ============================================================
-- TABLA: fattening_entries
-- MÓDULO: Engorde — Ingreso al Ciclo de Engorde
-- ============================================================
--
-- DESCRIPCIÓN:
--   Registra el ingreso formal de un animal al ciclo de Engorde.
--   Un animal puede llegar a Engorde desde Recría (rearing_selection
--   con destination='fattening') o por compra directa (animal_purchases
--   con el animal ya en estado Engorde).
--
-- REGLAS DE NEGOCIO:
--   - RN-09: Un animal pasa a Engorde solo si está en Recría Y la estancia
--             tiene el rubro Engorde habilitado (ranch_production_types).
--   - RF-06.1: Registrar fecha, peso inicial y tipo de sistema.
--
-- LÓGICA BACKEND (al registrar un ingreso a engorde):
--   1. Verificar que el animal tiene id_productive_status=2 (Recría)
--   2. Verificar que la estancia tiene id_production_type=3 (Engorde) activo
--   3. Crear animal_event (id_event_type=14 'fattening_entry')
--   4. Crear fattening_entries
--   5. Actualizar ranch_animals: id_productive_status=3 (Fattening)
--
-- INDICADORES DEL CICLO DE ENGORDE (calculados, no almacenados):
--   - Ganancia de peso: weight_records (pesajes posteriores) - initial_weight
--   - Conversión alimenticia (RF-06.4):
--       consumo = SUM(feed_records.quantity) del lote en el período
--       ganancia = SUM(delta de weight_records) del animal en el período
--       eficiencia = consumo / ganancia
--   - La salida comercial se registra en animal_sales (Movimientos)
--   - El retiro sanitario que puede bloquear la venta: treatments.withdrawal_end_date
--
-- CAMPOS:
--   - system_type:    field=campo abierto | feedlot=corral de engorde
--   - initial_weight: peso al inicio del ciclo de engorde (base para calcular ganancia)
-- ============================================================

CREATE TABLE fattening_entries (
    id_entry            BIGSERIAL,
    id_event            BIGINT          NOT NULL,
    system_type         VARCHAR(20)     NOT NULL
        CHECK (system_type IN (
            'field',      -- campo abierto
            'feedlot'     -- corral de engorde
        )),
    initial_weight      NUMERIC(8,2),             -- peso base del ciclo; weight_records registra los siguientes
    notes               TEXT,
    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_entry),
    FOREIGN KEY (id_event) REFERENCES animal_events(id_animal_event)
);
