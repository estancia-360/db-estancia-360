-- ============================================================
-- TABLA: productive_statuses  [CATÁLOGO — datos fijos del sistema]
-- MÓDULO: Animales
-- ============================================================
-- Etapas del ciclo de vida productivo bovino.
-- El backend actualiza id_productive_status en ranch_animals
-- automáticamente con cada transición del ciclo.
--
-- VALORES FIJOS (data.sql) y su flujo:
--   1=Breeding (Cría)    → Estado inicial de todo animal nacido/comprado
--   2=Rearing  (Recría)  → Se asigna automáticamente al destetar (weanings)
--   3=Fattening(Engorde) → Se asigna al ingresar a engorde (fattening_entries)
--   4=Discharged(Baja)   → Se asigna al vender (animal_sales) o morir (animal_exits)
--
-- RN-10: Un animal en estado 4 (Baja) no puede reactivarse.
-- ============================================================

CREATE TABLE productive_statuses (
    id_productive_status int,
    name VARCHAR(50) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    primary key (id_productive_status)
);