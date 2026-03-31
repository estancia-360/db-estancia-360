-- ============================================================
-- TABLA: animal_sales
-- MÓDULO: Movimientos — Venta de Animales
-- ============================================================
--
-- DESCRIPCIÓN:
--   Registra la venta de un animal. Es el evento de salida comercial.
--   Al registrar una venta, el animal pasa a estado Baja (Discharged).
--
-- REGLAS DE NEGOCIO:
--   - RN-16: Solo el Dueño (Owner) puede ejecutar ventas.
--   - RN-18 / RF-06.6: Un animal con período de retiro sanitario activo
--     NO puede registrarse como vendido. El backend debe verificar que
--     treatments.withdrawal_end_date < CURRENT_DATE para el animal.
--   - RF-06.5: Se debe registrar fecha, peso final, precio por kg y comprador.
--
-- LÓGICA BACKEND (al registrar una venta):
--   1. Verificar que quien registra es Owner (id_role=1 en ranch_users)
--   2. Verificar que el animal no tiene tratamiento con withdrawal_end_date >= HOY
--      (SELECT * FROM treatments t JOIN animal_events ae ON ... WHERE withdrawal_end_date >= NOW())
--   3. Crear animal_event (id_event_type=8 'sale')
--   4. Crear animal_sales
--   5. Actualizar ranch_animals: id_productive_status=4 (Baja), id_status=3 (Inactivo)
--
-- CAMPOS:
--   - buyer:       nombre del comprador
--   - destination: destino/frigorífico al que va el animal
--   - sale_price:  precio total de venta
--   - price_per_kg:precio por kilogramo
-- ============================================================

CREATE TABLE animal_sales (
    id_sale             BIGSERIAL,
    id_event            BIGINT          NOT NULL,
    buyer               VARCHAR(150),
    destination         VARCHAR(150),
    sale_price          NUMERIC(12,2),
    price_per_kg        NUMERIC(8,2),
    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_sale),
    FOREIGN KEY (id_event) REFERENCES animal_events(id_animal_event)
);
