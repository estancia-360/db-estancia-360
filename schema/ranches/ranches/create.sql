-- ============================================================
-- TABLA: ranches
-- MÓDULO: Gestión de Estancias
-- ============================================================
--
-- DESCRIPCIÓN:
--   Representa una unidad productiva ganadera. Es el contenedor de todos
--   los recursos del sistema: animales, potreros, lotes y usuarios.
--   Cada animal, potrero y lote pertenece a exactamente una estancia.
--
-- RUBROS PRODUCTIVOS:
--   Los rubros activos (Cría, Recría, Engorde) se gestionan en la tabla
--   ranch_production_types (relación ManyToMany). Una estancia puede
--   tener uno o más rubros habilitados (RF-01.4).
--   RF-01.5: Los módulos productivos solo operan si el rubro está habilitado.
--
-- REGLAS DE NEGOCIO:
--   - RN-01: Cada estancia tiene un único dueño (Owner en ranch_users).
--   - RN-02: Toda estancia debe tener al menos un rubro productivo activo.
--   - RF-01.1: Se registra con nombre, ciudad (→ región → país).
--
-- USUARIOS DE LA ESTANCIA:
--   Se gestionan en ranch_users. Los roles posibles son:
--   Owner (Dueño), Administrator (Administrador), Worker (Trabajador).
--
-- LÓGICA BACKEND (al crear una estancia):
--   1. Crear el registro en ranches
--   2. Crear ranch_users para el creador con id_role=1 (Owner)
--   3. Crear ranch_production_types con los rubros seleccionados
--
-- NOTA: No tiene id_production_type directo. Los rubros están en
--   ranch_production_types para soportar múltiples rubros por estancia.
-- ============================================================

CREATE TABLE ranches (
    id_ranch    SERIAL,
    id_city     INT             NOT NULL,
    name        VARCHAR(200)    NOT NULL,
    created_at  TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_ranch),
    FOREIGN KEY (id_city) REFERENCES cities(id_city)
);
