-- ============================================================
-- TABLA: animal_statuses  [CATÁLOGO — datos fijos del sistema]
-- MÓDULO: Animales
-- ============================================================
-- Estado operativo del animal (independiente del estado productivo).
-- Un animal puede estar en Engorde (productivo) y En Observación (operativo)
-- al mismo tiempo si tiene una cuarentena activa.
--
-- VALORES FIJOS (data.sql):
--   1=Activo       — Estado normal
--   2=En observación — Cuarentena o seguimiento especial (health_incidents)
--   3=Inactivo     — Animal dado de baja del sistema (al registrar salida o venta)
-- ============================================================

CREATE TABLE animal_statuses (
    id_status SERIAL,
    name VARCHAR(30) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (id_status)
);
