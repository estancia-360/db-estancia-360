-- ============================================================
-- TABLA: animal_statuses  [CATÁLOGO — datos fijos del sistema]
-- MÓDULO: Animales
-- ============================================================
-- Estado operativo del animal (independiente del estado productivo).
-- Un animal puede estar en Engorde (productivo) y En Observación (operativo)
-- al mismo tiempo si tiene una cuarentena activa.
--
-- VALORES FIJOS (data.sql):
--   1=Activo                  — Estado operativo normal
--   2=En observación          — Cuarentena o seguimiento especial (health_incidents)
--   3=Inactivo                — Animal dado de baja por muerte/descarte (animal_exits)
--   4=Pendiente de Movimiento — Temporal durante una venta activa (movements.status='pending')
--                               Al confirmar → pasa a 5 (accepted) o revierte a 1 (rejected)
--   5=Vendido                 — Estado final tras aceptación en venta confirmada
--                               id_productive_status=4 (Baja) se setea junto a este estado
--
-- NOTA: id=3 (Inactivo) es para animal_exits (muerte/descarte/pérdida).
--       id=5 (Vendido) es exclusivo del flujo de ventas (movements type='sale').
--       Ambos son estados terminales pero con origen y semántica distintos.
-- ============================================================

CREATE TABLE animal_statuses (
    id_status SERIAL,
    name VARCHAR(30) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (id_status)
);
