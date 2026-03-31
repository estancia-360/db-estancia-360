-- ============================================================
-- TABLA: animal_purchases
-- MÓDULO: Movimientos — Compra de Animales
-- ============================================================
--
-- DESCRIPCIÓN:
--   Registra la compra de un animal externo que ingresa a la estancia.
--   Al registrar una compra, el backend también crea automáticamente el
--   registro del nuevo animal en ranch_animals (RF-08.2).
--
-- REGLAS DE NEGOCIO:
--   - RN-16: Solo el Dueño (Owner) puede ejecutar y aprobar compras.
--   - RF-08.2: Al comprar se crea automáticamente el animal en el sistema.
--   - El animal creado puede entrar en cualquier estado productivo según
--     su etapa de vida (Cría, Recría o Engorde).
--
-- LÓGICA BACKEND (al registrar una compra):
--   1. Verificar que quien registra es Owner (id_role=1 en ranch_users)
--   2. Crear el animal en ranch_animals con los datos del formulario
--   3. Crear animal_event (id_event_type=7 'purchase') para el nuevo animal
--   4. Crear animal_purchases con los datos comerciales
--
-- CAMPOS:
--   - supplier:       nombre del proveedor / vendedor
--   - origin:         lugar de procedencia del animal
--   - purchase_price: precio total de compra
--   - price_per_kg:   precio por kilogramo (indicador comercial)
-- ============================================================

CREATE TABLE animal_purchases (
    id_purchase         BIGSERIAL,
    id_event            BIGINT          NOT NULL,
    supplier            VARCHAR(150),
    origin              VARCHAR(150),
    purchase_price      NUMERIC(12,2),
    price_per_kg        NUMERIC(8,2),
    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_purchase),
    FOREIGN KEY (id_event) REFERENCES animal_events(id_animal_event)
);
